# ── Project ──────────────────────────────────────────────────────────────────

variable "project_id" {
  description = "GCP project ID where lab IAM bindings are created."
  type        = string
}

variable "region" {
  description = "Default GCP region."
  type        = string
  default     = "us-central1"
}

variable "lab_batch" {
  description = "Training batch identifier, e.g. 'june-2026-batch1'. Used in labels and state prefix."
  type        = string
}

# ── Identity mode ─────────────────────────────────────────────────────────────

variable "use_cloud_identity" {
  description = <<-EOT
    true  → Create new Cloud Identity users under identity_domain.
            Requires Google Workspace / Cloud Identity Free domain + service
            account with domain-wide delegation.
    false → Use pre-existing Google accounts. Each student must supply an email.
  EOT
  type    = bool
  default = false
}

variable "identity_domain" {
  description = "Email domain for Cloud Identity users (e.g. training.example.com). Required when use_cloud_identity = true."
  type        = string
  default     = ""
}

variable "workspace_customer_id" {
  description = "Google Workspace customer ID (Admin Console → Account → Settings). Required when use_cloud_identity = true."
  type        = string
  default     = ""
}

variable "workspace_sa_credentials_file" {
  description = "Path to service account JSON key with domain-wide delegation. Required when use_cloud_identity = true."
  type        = string
  default     = ""
  sensitive   = true
}

variable "workspace_admin_email" {
  description = "Super-admin email for domain-wide delegation. Required when use_cloud_identity = true."
  type        = string
  default     = ""
}

# ── IAM behaviour ─────────────────────────────────────────────────────────────

variable "enable_expiry_condition" {
  description = <<-EOT
    Attach a time-based IAM condition so access auto-expires after lab_expiry_days.
    Set false if the project/org has not enabled IAM Conditions, or if assigned
    roles do not support conditions (e.g. primitive roles owner/editor/viewer).
  EOT
  type    = bool
  default = false
}

# ── Students ──────────────────────────────────────────────────────────────────

variable "students" {
  description = <<-EOT
    Map of students to provision. Key is a short stable identifier (e.g. 'student01').
    - display_name    : Full name shown in access card.
    - username        : Used as the Cloud Identity username or for naming.
    - email           : Required when use_cloud_identity = false.
    - roles           : IAM roles to grant on project_id.
    - lab_expiry_days : Days from first apply until access expires.
  EOT
  type = map(object({
    display_name    = string
    username        = string
    email           = optional(string, "")
    roles           = list(string)
    lab_expiry_days = number
  }))

  validation {
    condition = alltrue([
      for k, v in var.students :
      can(regex("^[a-z][a-z0-9-]{0,28}[a-z0-9]$", v.username))
    ])
    error_message = "Each student username must be 2-30 lowercase alphanumeric characters or hyphens, starting and ending with a letter or digit."
  }

  validation {
    condition = alltrue([
      for k, v in var.students : v.lab_expiry_days > 0 && v.lab_expiry_days <= 365
    ])
    error_message = "lab_expiry_days must be between 1 and 365."
  }
}
