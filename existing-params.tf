locals {
  existing_params = {
    for key, value in var.parameters : key => value
    if value.value_from_arn != null
  }

  existing_params_keys_set = nonsensitive(toset(keys(local.existing_params)))
}

data "aws_ssm_parameter" "existing" {
  for_each = local.existing_params_keys_set

  name = local.existing_params[each.key]
}
