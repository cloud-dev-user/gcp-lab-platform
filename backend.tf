# Partial backend — values are supplied at terraform init time.
#
# Usage:
#   terraform init \
#     -backend-config="bucket=YOUR_STATE_BUCKET" \
#     -backend-config="prefix=lab-platform/june-2026-batch1"
#
# Using a per-batch prefix isolates state per training run, making it safe
# to destroy one batch without touching another.

terraform {
  backend "gcs" {}
}
