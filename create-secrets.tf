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

resource "aws_secretsmanager_secret" "secrets" {
  for_each = local.secrets_to_create_keys_set

  name        = module.secret_path[each.key].id
  description = local.secrets_to_create[each.key].description
  kms_key_id  = data.aws_kms_key.kms_key.arn

  tags = module.secret_path[each.key].tags
}

resource "aws_secretsmanager_secret_version" "secrets" {
  for_each = local.secrets_to_create_keys_set

  secret_id = aws_secretsmanager_secret.secrets[each.key].id

  secret_string = local.secrets_to_create[each.key].value
}
