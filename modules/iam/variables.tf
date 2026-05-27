variable "project_id" {
  description = "GCP project ID where IAM bindings are created."
  type        = string
}

variable "student_email" {
  description = "Student's Google account email used as the IAM member."
  type        = string
}

variable "student_name" {
  description = "Student display name — used only in IAM condition description."
  type        = string
}

variable "roles" {
  description = "List of IAM roles to grant (e.g. [\"roles/viewer\", \"roles/storage.objectViewer\"])."
  type        = list(string)
}

variable "expiry_date" {
  description = "RFC3339 datetime used in the IAM condition expression."
  type        = string
}

variable "lab_batch" {
  description = "Training batch identifier — used in condition title for traceability."
  type        = string
}

variable "enable_expiry_condition" {
  description = "Attach a time-based IAM condition to auto-expire access. Requires IAM Conditions API. Not supported on primitive roles (owner/editor/viewer)."
  type        = bool
  default     = false
}
