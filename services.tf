locals {
  lab_services = toset([
    # ── Module 1–2: Core Platform & IAM ───────────────────────────────────────
    "cloudresourcemanager.googleapis.com", # Resource hierarchy (org/folder/project)
    "iam.googleapis.com",                  # IAM API, service accounts, custom roles

    # ── Module 3: Compute ─────────────────────────────────────────────────────
    "compute.googleapis.com",              # GCE, instance groups, autoscaling,
                                           # VPC, firewall, load balancing,
                                           # Cloud CDN, VPN, Cloud Interconnect
    "container.googleapis.com",            # Google Kubernetes Engine
    "appengine.googleapis.com",            # App Engine
    "cloudfunctions.googleapis.com",       # Cloud Functions (1st gen)
    "run.googleapis.com",                  # Cloud Run (2nd-gen Functions runtime)

    # ── Module 4: Storage & Databases ─────────────────────────────────────────
    "storage.googleapis.com",              # Cloud Storage buckets
    "sqladmin.googleapis.com",             # Cloud SQL
    "servicenetworking.googleapis.com",    # Private IP for Cloud SQL / other services
    "bigtable.googleapis.com",             # Bigtable data plane
    "bigtableadmin.googleapis.com",        # Bigtable control plane (instance creation)
    "firestore.googleapis.com",            # Firestore / Datastore

    # ── Module 5: Networking ──────────────────────────────────────────────────
    "dns.googleapis.com",                  # Cloud DNS

    # ── Module 6: Deployment & Management ────────────────────────────────────
    "deploymentmanager.googleapis.com",    # Deployment Manager (IaC)
    "monitoring.googleapis.com",           # Cloud Monitoring
    "logging.googleapis.com",              # Cloud Logging

    # ── Module 7: Security & Compliance ──────────────────────────────────────
    "cloudkms.googleapis.com",             # Cloud KMS — encryption key management
    "secretmanager.googleapis.com",        # Secret Manager — secrets & credentials

    # ── Module 9: DevOps & Automation ────────────────────────────────────────
    "cloudbuild.googleapis.com",           # Cloud Build (CI/CD)
    "artifactregistry.googleapis.com",     # Artifact Registry — container images / packages
  ])
}

resource "google_project_service" "lab_apis" {
  for_each = local.lab_services

  project = var.project_id
  service = each.value

  # Keep APIs enabled even if this Terraform config is destroyed —
  # tearing down student IAM bindings should not disable shared project APIs.
  disable_on_destroy         = false
  disable_dependent_services = false
}
