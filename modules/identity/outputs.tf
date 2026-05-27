output "email" {
  description = "Student's Google account email (created or pre-existing)."
  value       = local.email
}

output "temp_password" {
  description = "Temporary password for new Cloud Identity accounts. Empty string for pre-existing accounts."
  value       = var.create_identity ? random_password.student[0].result : ""
  sensitive   = true
}
