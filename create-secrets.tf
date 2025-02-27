locals {
  secrets_to_create = {
    for key, value in var.secrets : key => value
    if contains(keys(value), "value")
  }
}

module "secret_path" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  for_each = local.secrets_to_create

  context    = module.path.context
  attributes = []
}

resource "aws_secretsmanager_secret" "secrets" {
  for_each = local.secrets_to_create

  name        = module.secret_path[each.key].id
  description = each.value.description
  kms_key_id  = var.kms_key_id

  tags = module.secret_path[each.key].tags
}

resource "aws_secretsmanager_secret_version" "secrets" {
  for_each = local.secrets_to_create

  secret_id = aws_secretsmanager_secret.secrets[each.key].id

  secret_string = each.value.value
}
