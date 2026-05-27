terraform {
  required_version = ">= 1.6"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    googleworkspace = {
      source  = "hashicorp/googleworkspace"
      version = "~> 0.7"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.11"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# Only active when use_cloud_identity = true.
# Requires a service account with domain-wide delegation configured in Google Workspace Admin.
provider "googleworkspace" {
  # When use_cloud_identity = false no workspace resources are created, but the
  # provider still validates customer_id at init. Pass a dummy so Mode A works
  # without needing to supply Workspace credentials.
  customer_id             = coalesce(var.workspace_customer_id, "not-used")
  credentials             = var.workspace_sa_credentials_file != "" ? var.workspace_sa_credentials_file : null
  impersonated_user_email = var.workspace_admin_email

  oauth_scopes = [
    "https://www.googleapis.com/auth/admin.directory.user",
    "https://www.googleapis.com/auth/admin.directory.group",
  ]
}
