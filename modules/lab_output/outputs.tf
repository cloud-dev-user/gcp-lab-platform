output "onboarding_message" {
  description = "Full access card content (sensitive — contains password)."
  value       = local.access_card
  sensitive   = true
}

output "console_url" {
  description = "GCP Console URL pre-scoped to the training project."
  value       = local.console_url
}

output "cloudshell_url" {
  description = "Direct Cloud Shell URL for the training project."
  value       = local.cloudshell_url
}
