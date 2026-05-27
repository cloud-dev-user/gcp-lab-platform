output "provisioned_students" {
  description = "Non-sensitive summary of all provisioned students."
  value = {
    for k in keys(var.students) : k => {
      display_name = var.students[k].display_name
      email        = module.identity[k].email
      roles        = var.students[k].roles
      expiry       = formatdate("DD MMM YYYY", time_offset.student_expiry[k].rfc3339)
      console_url  = module.lab_output[k].console_url
      cloudshell_url = module.lab_output[k].cloudshell_url
    }
  }
}

# Marked sensitive because it contains passwords for Cloud Identity mode.
output "student_credentials" {
  description = "Full credentials including passwords. Use: terraform output -json student_credentials"
  sensitive   = true
  value = {
    for k in keys(var.students) : k => {
      email         = module.identity[k].email
      temp_password = module.identity[k].temp_password
      project_id    = var.project_id
      console_url   = module.lab_output[k].console_url
      cloudshell_url = module.lab_output[k].cloudshell_url
      roles         = var.students[k].roles
      expiry        = time_offset.student_expiry[k].rfc3339
    }
  }
}

output "access_cards_directory" {
  description = "Local path where per-student access card text files are written."
  value       = "${path.root}/access-cards"
}
