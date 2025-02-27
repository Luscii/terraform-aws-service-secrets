locals {
  existing_secrets = {
    for key, value in var.secrets : key => value.value_from_arn
    if contains(keys(value), "value_from_arn")
  }
}

data "aws_secretsmanager_secret" "existing" {
  for_each = local.existing_secrets

  arn = each.value
}
