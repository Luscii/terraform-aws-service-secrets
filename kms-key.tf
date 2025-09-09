data "aws_kms_key" "kms_key" {
  count = var.kms_key_id != null && var.kms_key_id != "" ? 1 : 0

  key_id = var.kms_key_id
}

locals {
  # Get KMS key IDs from existing secrets
  existing_secrets_kms_keys = flatten([
    for key in local.existing_secrets_keys_set :
    data.aws_secretsmanager_secret.existing[key].kms_key_id if data.aws_secretsmanager_secret.existing[key].kms_key_id != null
  ])

  # Combine all KMS keys in use
  secrets_kms_keys = distinct(compact(concat([var.kms_key_id], local.existing_secrets_kms_keys)))
}

data "aws_kms_key" "secrets" {
  for_each = toset(local.secrets_kms_keys)

  key_id = each.value
}
