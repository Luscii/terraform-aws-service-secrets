locals {
  existing_params = {
    for key, value in var.parameters : key => value
    if value.value_from_arn != null
  }

  existing_params_keys_set = nonsensitive(toset(keys(local.existing_params)))

  # Extract parameter name from ARN (format: arn:aws:ssm:region:account:parameter/name)
  # This works for parameters created with and without a path structure
  params_names = {
    for key, value in local.existing_params : key => (
      # Check if this is a valid SSM parameter ARN format
      length(regexall("^arn:aws:ssm:[^:]+:[^:]+:parameter/", value.value_from_arn)) > 0
      # If it is, extract the name (everything after "parameter/")
      ? replace(value.value_from_arn, "^arn:aws:ssm:[^:]+:[^:]+:parameter/", "")
      # Otherwise use as is (assuming it might be a direct parameter name)
      : value.value_from_arn
    )
  }
}

data "aws_ssm_parameter" "existing" {
  for_each = local.existing_params_keys_set

  name = local.params_names[each.key]
}
