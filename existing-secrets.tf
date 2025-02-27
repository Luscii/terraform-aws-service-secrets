locals {
  existing_secrets = {
    for key, value in var.secrets : key => value.value_from_arn
    if contains(keys(value), "value_from_arn")
  }

  existing_secrets_keys_set = toset(keys(local.existing_secrets))
}

data "aws_secretsmanager_secret" "existing" {
  for_each = local.existing_secrets_keys_set

  arn = local.existing_secrets[each.key]
}
