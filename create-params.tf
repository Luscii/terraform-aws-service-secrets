locals {
  params_to_create = {
    for key, value in var.parameters : key => value
    if value.value != null
  }
  params_to_create_keys_set = nonsensitive(toset(keys(local.params_to_create)))
}

module "param_path" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  for_each = local.params_to_create_keys_set

  context    = module.path.context
  attributes = [each.key]
}

locals {
  # Special prefix for webhook integration parameters
  webhook_integration_prefix = "/d9d01087-4a3f-49e0-b0b4-d568d7826553/ssm/integrations/webhook/"

  # Determine name, type, and key_id based on parameter data_type
  param_names = {
    for key, value in local.params_to_create : key => (
      value.data_type == "aws:ssm:integration"
      ? "${local.webhook_integration_prefix}${key}"
      : module.param_path[key].id
    )
  }

  param_types = {
    for key, value in local.params_to_create : key => (
      value.data_type == "aws:ssm:integration"
      ? "SecureString"
      : (value.sensitive ? "SecureString" : "String")
    )
  }

  param_key_ids = {
    for key, value in local.params_to_create : key => (
      value.data_type == "aws:ssm:integration"
      ? null
      : (value.sensitive ? data.aws_kms_key.kms_key.arn : null)
    )
  }
}

resource "aws_ssm_parameter" "param" {
  for_each = local.params_to_create_keys_set

  name        = local.param_names[each.key]
  description = local.params_to_create[each.key].description
  type        = local.param_types[each.key]
  key_id      = local.param_key_ids[each.key]
  value       = local.params_to_create[each.key].value
  data_type   = local.params_to_create[each.key].data_type

  tags = module.param_path[each.key].tags
}
