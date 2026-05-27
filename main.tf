# ── Expiry timestamps ─────────────────────────────────────────────────────────
# time_offset is written to state on first apply and never changes on re-apply,
# so IAM condition expressions remain stable across plan/apply cycles.

resource "time_offset" "student_expiry" {
  for_each    = var.students
  offset_days = each.value.lab_expiry_days
}

# ── Identity ──────────────────────────────────────────────────────────────────
# Mode A (use_cloud_identity=true):  creates Cloud Identity user, generates password.
# Mode B (use_cloud_identity=false): passes through the supplied email, no user created.

module "identity" {
  source   = "./modules/identity"
  for_each = var.students

  username        = each.value.username
  display_name    = each.value.display_name
  email           = each.value.email
  domain          = var.identity_domain
  create_identity = var.use_cloud_identity
  expiry_date     = time_offset.student_expiry[each.key].rfc3339
  lab_batch       = var.lab_batch
}

# ── IAM bindings ──────────────────────────────────────────────────────────────
# Uses google_project_iam_member only — purely additive.
# Existing project IAM bindings are never read, overwritten, or deleted.

module "iam" {
  source   = "./modules/iam"
  for_each = var.students

  project_id              = var.project_id
  student_email           = module.identity[each.key].email
  student_name            = each.value.display_name
  roles                   = each.value.roles
  expiry_date             = time_offset.student_expiry[each.key].rfc3339
  lab_batch               = var.lab_batch
  enable_expiry_condition = var.enable_expiry_condition
}

# ── Access cards ──────────────────────────────────────────────────────────────
# Writes one plaintext file per student to ./access-cards/<key>.txt

module "lab_output" {
  source   = "./modules/lab_output"
  for_each = var.students

  student_key        = each.key
  display_name       = each.value.display_name
  email              = module.identity[each.key].email
  temp_password      = module.identity[each.key].temp_password
  roles              = each.value.roles
  project_id         = var.project_id
  expiry_date        = time_offset.student_expiry[each.key].rfc3339
  use_cloud_identity = var.use_cloud_identity
}
