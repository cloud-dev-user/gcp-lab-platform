# GCP Lab Platform

Terraform-based platform for provisioning training lab access on GCP. Provisions student identities, grants project IAM roles, and generates printable access cards — all safely, without touching existing project permissions.

---

## Folder Structure

```
gcp-lab-platform/
├── main.tf                          # Root: wires modules together
├── variables.tf                     # All input variables
├── outputs.tf                       # Student summary + credentials output
├── versions.tf                      # Provider versions + provider config
├── backend.tf                       # Partial GCS backend (bucket at init time)
├── terraform.tfvars.example         # Copy → terraform.auto.tfvars
├── .gitignore                       # Excludes state, keys, access cards
│
├── modules/
│   ├── identity/                    # Creates Cloud Identity users OR passes Gmail
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── iam/                         # Grants project IAM roles (additive only)
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── lab_output/                  # Generates per-student access card .txt files
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
│
├── access-cards/                    # Auto-created on apply (gitignored)
│   ├── student01.txt
│   └── student02.txt
│
└── .github/workflows/
    ├── provision.yml                # Manual trigger: plan or apply
    └── destroy-expired.yml          # Scheduled + manual: full destroy
```

---

## IAM Safety — Why google_project_iam_member

This platform uses **only** `google_project_iam_member`. Here is why the alternatives are dangerous:

| Resource | Behaviour | Risk |
|---|---|---|
| `google_project_iam_policy` | Authoritative — **replaces the entire project IAM policy** on every apply | Deletes all bindings Terraform doesn't know about. One apply wipes your project's existing access. |
| `google_project_iam_binding` | Authoritative per role — **replaces all members** for a given role | Any pre-existing user in that role is removed. Safe only if Terraform owns 100% of that role. |
| `google_project_iam_member` | **Additive** — adds one member+role pair only | Existing bindings for all other users are never read, compared, or modified. `terraform destroy` removes only what Terraform created. **This is the safe choice.** |

**Bottom line:** with `google_project_iam_member`, the worst a `terraform destroy` can do is remove the bindings this platform created. Nothing else in the project is ever touched.

---

## Identity Modes

### Mode A — Pre-existing Gmail accounts (no domain required)
Each student uses an existing Google account (`@gmail.com` or any Google-managed email). You create the accounts once, Terraform only manages the IAM bindings.

```hcl
use_cloud_identity = false

students = {
  student01 = {
    display_name    = "Lab User 01"
    username        = "lab-user-01"
    email           = "gcp.training.lab01@gmail.com"
    lab_expiry_days = 10
    roles           = ["roles/viewer", "roles/storage.objectViewer"]
  }
}
```

### Mode B — Cloud Identity managed accounts (domain required)
Terraform creates `lab01@yourdomain.com`, generates a password, and grants project access. Participants get a clean managed account with no personal data.

**Prerequisites:**
1. Own a domain (even a free one works)
2. Enable [Google Cloud Identity Free](https://workspace.google.com/intl/en/products/cloud-identity/) for that domain
3. Create a service account with **domain-wide delegation** in Google Workspace Admin
4. Grant it the `https://www.googleapis.com/auth/admin.directory.user` scope

```hcl
use_cloud_identity            = true
identity_domain               = "training.yourcompany.com"
workspace_customer_id         = "C0xxxxxxx"
workspace_admin_email         = "admin@yourcompany.com"
workspace_sa_credentials_file = "./creds/workspace-sa.json"
```

---

## Quick Start (Mode A — Gmail)

### 1. Prerequisites

```bash
# GCP: create a state bucket
gsutil mb -p orange-gcp-training gs://orange-gcp-training-tf-state

# Authenticate
gcloud auth application-default login
```

### 2. Configure students

```bash
cp terraform.tfvars.example terraform.auto.tfvars
# Edit terraform.auto.tfvars — fill in real Gmail addresses
```

### 3. Init and apply

```bash
terraform init \
  -backend-config="bucket=orange-gcp-training-tf-state" \
  -backend-config="prefix=lab-platform/june-2026-batch1"

terraform validate
terraform plan
terraform apply
```

### 4. Distribute access cards

After apply, one file per student is written to `./access-cards/`.

```bash
ls access-cards/
# student01.txt  student02.txt  student03.txt

cat access-cards/student01.txt
```

Print them or share via a secure channel. Each file contains the email, password, project ID, and step-by-step login instructions.

### 5. View output summary

```bash
# Non-sensitive summary
terraform output provisioned_students

# Full credentials (JSON) — sensitive
terraform output -json student_credentials
```

---

## Adding More Students

Edit `terraform.auto.tfvars` and add entries to the `students` map:

```hcl
students = {
  # existing students...
  student04 = {
    display_name    = "Lab User 04"
    username        = "lab-user-04"
    email           = "gcp.training.lab04@gmail.com"
    lab_expiry_days = 10
    roles           = ["roles/viewer"]
  }
}
```

```bash
terraform apply   # Only adds new bindings; existing students are untouched
```

---

## Removing Students (End of Training)

```bash
# Remove all students from this batch
terraform destroy

# Remove one specific student only
terraform destroy -target='module.iam["student01"]' \
                  -target='module.identity["student01"]' \
                  -target='module.lab_output["student01"]' \
                  -target='time_offset.student_expiry["student01"]'
```

---

## IAM Expiry Conditions (Optional)

Setting `enable_expiry_condition = true` attaches a time-based IAM condition so access automatically stops working after `lab_expiry_days` — even if you forget to run destroy.

**Requirements:**
- IAM Conditions API must be enabled on the project
- Does **not** work with primitive roles (`roles/owner`, `roles/editor`, `roles/viewer`)
- Works with all predefined and custom roles

```hcl
enable_expiry_condition = true   # recommended for production training
```

---

## GitHub Actions Setup

### Repository secrets and variables

| Name | Type | Value |
|---|---|---|
| `WIF_PROVIDER` | Secret | Workload Identity Federation provider resource name |
| `TF_SERVICE_ACCOUNT` | Secret | Terraform runner service account email |
| `STATE_BUCKET` | Variable | GCS bucket name for Terraform state |
| `GCP_PROJECT_ID` | Variable | GCP project ID |
| `ACTIVE_LAB_BATCH` | Variable | Current batch name for scheduled destroy |

### Provisioning a batch (Actions UI)

1. Go to **Actions → Provision Lab Students → Run workflow**
2. Set `action = plan`, `lab_batch = june-2026-batch1`
3. Review the plan output in the logs
4. Re-run with `action = apply`
5. Download the `access-cards-june-2026-batch1` artifact (auto-deleted after 1 day)

### Destroying a batch (manual)

1. Go to **Actions → Destroy Expired Lab Students → Run workflow**
2. Enter `lab_batch` and type `DESTROY` in the confirm field

### Scheduled auto-destroy

The `destroy-expired.yml` workflow runs daily at 02:00 UTC. Set the `ACTIVE_LAB_BATCH` repository variable to the current batch. Update it when you start a new batch.

---

## Import Existing Bindings

If IAM bindings were created outside Terraform and you want to bring them under management:

```bash
# Format: terraform import 'module.iam["<key>"].google_project_iam_member.student_roles["<role_key>"]' \
#           "<project_id> <role> <member>"

terraform import \
  'module.iam["student01"].google_project_iam_member.student_roles["viewer"]' \
  "orange-gcp-training roles/viewer user:gcp.training.lab01@gmail.com"
```

---

## Validation Checks

```bash
# Validate HCL syntax and module references
terraform validate

# Confirm only additive IAM resources in the plan (no iam_policy or iam_binding)
terraform plan | grep -E "google_project_iam_(policy|binding)" && echo "UNSAFE" || echo "SAFE"

# List all IAM members Terraform manages in this state
terraform state list | grep google_project_iam_member

# Check what roles a student has
gcloud projects get-iam-policy orange-gcp-training \
  --flatten="bindings[].members" \
  --format="table(bindings.role,bindings.members)" \
  --filter="bindings.members:gcp.training.lab01@gmail.com"
```

---

## Participant Login (Quick Reference)

Share this with students:

1. Go to **https://console.cloud.google.com**
2. Sign in with the email and password on your access card
3. Select project **orange-gcp-training** from the project picker
4. Click the **>_** icon (top right) to open Cloud Shell
5. Run `gcloud auth list` to confirm your identity
