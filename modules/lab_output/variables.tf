variable "student_key" {
  description = "Map key identifying this student — used as the filename."
  type        = string
}

variable "display_name" {
  description = "Student's full display name."
  type        = string
}

variable "email" {
  description = "Student's Google account email."
  type        = string
}

variable "temp_password" {
  description = "Temporary password for new Cloud Identity accounts. Empty for pre-existing accounts."
  type        = string
  sensitive   = true
}

variable "roles" {
  description = "List of IAM roles assigned to this student."
  type        = list(string)
}

variable "project_id" {
  description = "GCP project ID."
  type        = string
}

variable "expiry_date" {
  description = "RFC3339 expiry datetime."
  type        = string
}

variable "use_cloud_identity" {
  description = "Whether Cloud Identity accounts were created (affects password line in access card)."
  type        = bool
}
