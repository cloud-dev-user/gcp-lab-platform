# ── Why google_project_iam_member and NOT google_project_iam_policy ───────────
#
# google_project_iam_policy   — AUTHORITATIVE. Replaces the ENTIRE project IAM
#                               policy on every apply. Any binding Terraform
#                               doesn't know about is silently deleted. Extremely
#                               dangerous in a shared project.
#
# google_project_iam_binding  — AUTHORITATIVE per role. Replaces all members for
#                               a given role. Safe only when Terraform owns 100%
#                               of that role's members — not true here.
#
# google_project_iam_member   — ADDITIVE. Adds exactly one member+role pair.
#                               Existing bindings for other users are never
#                               read, compared, or modified. terraform destroy
#                               removes only what Terraform created.
#                               This is the only safe choice for shared projects.
# ─────────────────────────────────────────────────────────────────────────────

locals {
  # Stable map key: "roles/storage.objectViewer" → "storage_objectViewer"
  role_bindings = {
    for role in var.roles :
    replace(trimprefix(role, "roles/"), ".", "_") => role
  }

  expiry_condition = {
    title       = "lab-expiry-${formatdate("YYYYMMdd", var.expiry_date)}"
    description = "Batch: ${var.lab_batch} | Student: ${var.student_name} | Expires: ${formatdate("DD MMM YYYY", var.expiry_date)}"
    expression  = "request.time < timestamp(\"${var.expiry_date}\")"
  }
}

resource "google_project_iam_member" "student_roles" {
  for_each = local.role_bindings

  project = var.project_id
  role    = each.value
  member  = "user:${var.student_email}"

  dynamic "condition" {
    for_each = var.enable_expiry_condition ? [1] : []
    content {
      title       = local.expiry_condition.title
      description = local.expiry_condition.description
      expression  = local.expiry_condition.expression
    }
  }
}
