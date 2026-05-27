terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
  }
}

locals {
  console_url    = "https://console.cloud.google.com/home/dashboard?project=${var.project_id}"
  cloudshell_url = "https://shell.cloud.google.com/?project=${var.project_id}"
  expiry_display = formatdate("DD MMM YYYY", var.expiry_date)
  password_line  = var.use_cloud_identity ? var.temp_password : "(your existing Google account password)"

  roles_formatted = join("\n", [for r in var.roles : "  |    • ${r}"])

  access_card = <<-EOT
  ┌─────────────────────────────────────────────────────────────┐
  │              GCP TRAINING LAB — ACCESS CARD                 │
  ├─────────────────────────────────────────────────────────────┤
  │  Name      : ${var.display_name}
  │  Email     : ${var.email}
  │  Password  : ${local.password_line}
  │  Project   : ${var.project_id}
  │  Expires   : ${local.expiry_display}
  ├─────────────────────────────────────────────────────────────┤
  │  ASSIGNED ROLES:
${local.roles_formatted}
  ├─────────────────────────────────────────────────────────────┤
  │  HOW TO ACCESS YOUR LAB:
  │
  │  1. Open browser → ${local.console_url}
  │  2. Sign in with the email and password above
  │  3. Confirm the project shows: ${var.project_id}
  │     (use the project picker in the top nav bar if needed)
  │  4. Click the  >_  icon (top-right) to open Cloud Shell
  │     OR go to: ${local.cloudshell_url}
  │
  │  Verify in Cloud Shell:
  │    $ gcloud auth list
  │    $ gcloud config get-value project
  └─────────────────────────────────────────────────────────────┘
  EOT
}

# Written to ./access-cards/<student_key>.txt relative to root module.
# Permission 0600 — readable only by the operator running Terraform.
resource "local_file" "access_card" {
  content         = local.access_card
  filename        = "${path.root}/access-cards/${var.student_key}.txt"
  file_permission = "0600"
}
