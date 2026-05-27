terraform {
  required_providers {
    googleworkspace = {
      source  = "hashicorp/googleworkspace"
      version = "~> 0.7"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

locals {
  email = var.create_identity ? "${var.username}@${var.domain}" : var.email

  name_parts  = split(" ", var.display_name)
  given_name  = local.name_parts[0]
  family_name = length(local.name_parts) > 1 ? join(" ", slice(local.name_parts, 1, length(local.name_parts))) : local.name_parts[0]
}

# Generates a strong temporary password for new Cloud Identity accounts.
resource "random_password" "student" {
  count            = var.create_identity ? 1 : 0
  length           = 14
  special          = true
  override_special = "!@#$%"
  min_upper        = 2
  min_lower        = 2
  min_numeric      = 2
  min_special      = 1
}

# Creates a managed Google account under identity_domain.
# Participants log in to console.cloud.google.com with this account.
resource "googleworkspace_user" "student" {
  count = var.create_identity ? 1 : 0

  primary_email = local.email

  name {
    given_name  = local.given_name
    family_name = local.family_name
  }

  password                      = random_password.student[0].result
  change_password_at_next_login = false
  is_admin                      = false
  suspended                     = false
}
