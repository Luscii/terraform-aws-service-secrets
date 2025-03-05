locals {
  existing_secrets = {
    for key, value in var.secrets : key => value.value_from_arn
    if value.value_from_arn != null
  }

  existing_secrets_keys_set = nonsensitive(toset(keys(local.existing_secrets)))
}

data "aws_secretsmanager_secret" "existing" {
  for_each = local.existing_secrets_keys_set

  arn = local.existing_secrets[each.key]
}
