variable "username" {
  description = "Username portion of the email (before the @)."
  type        = string
}

variable "display_name" {
  description = "Student's full display name."
  type        = string
}

variable "domain" {
  description = "Email domain for Cloud Identity users. Required when create_identity = true."
  type        = string
  default     = ""
}

variable "email" {
  description = "Pre-existing Google account email. Required when create_identity = false."
  type        = string
  default     = ""
}

variable "create_identity" {
  description = "When true, creates a Cloud Identity user via the googleworkspace provider."
  type        = bool
  default     = false
}

variable "expiry_date" {
  description = "RFC3339 datetime when this student's access expires. Stored as a user attribute."
  type        = string
}

variable "lab_batch" {
  description = "Training batch identifier. Stored as a user attribute."
  type        = string
}
