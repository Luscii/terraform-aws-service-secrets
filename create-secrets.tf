locals {
  secrets_to_create = {
    for key, value in var.secrets : key => value
    if value.value != null
  }
  secrets_to_create_keys_set = nonsensitive(toset(keys(local.secrets_to_create)))
}

module "secret_path" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  for_each = local.secrets_to_create_keys_set

  context    = module.path.context
  attributes = [each.key]
}

locals {
  # Only create secrets if there are secrets to create AND a kms_key_id is provided
  create_secrets = length(local.secrets_to_create_keys_set) > 0 && var.kms_key_id != null && var.kms_key_id != ""

  # Set of secrets to actually create based on the conditions
  secrets_to_actually_create = local.create_secrets ? local.secrets_to_create_keys_set : []
}

resource "aws_secretsmanager_secret" "secrets" {
  for_each = toset(local.secrets_to_actually_create)

  name        = module.secret_path[each.key].id
  description = local.secrets_to_create[each.key].description
  kms_key_id  = data.aws_kms_key.kms_key[0].arn

  tags = module.secret_path[each.key].tags
}

resource "aws_secretsmanager_secret_version" "secrets" {
  for_each = toset(local.secrets_to_actually_create)

  secret_id = aws_secretsmanager_secret.secrets[each.key].id

  secret_string = local.secrets_to_create[each.key].value
}
