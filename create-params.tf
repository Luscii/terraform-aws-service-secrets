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

resource "aws_ssm_parameter" "param" {
  for_each = local.params_to_create_keys_set

  name        = module.param_path[each.key].id
  description = local.params_to_create[each.key].description

  type      = local.params_to_create[each.key].sensitive ? "SecureString" : "String"
  key_id    = local.params_to_create[each.key].sensitive ? data.aws_kms_key.kms_key.arn : null
  value     = local.params_to_create[each.key].value
  data_type = local.params_to_create[each.key].data_type

  tags = module.param_path[each.key].tags
}
