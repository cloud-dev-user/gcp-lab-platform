output "iam_bindings" {
  description = "Map of IAM bindings created for this student."
  value = {
    for k, v in google_project_iam_member.student_roles : k => {
      role   = v.role
      member = v.member
    }
  }
}

output "binding_count" {
  description = "Number of IAM role bindings created for this student."
  value       = length(google_project_iam_member.student_roles)
}
