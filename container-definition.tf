locals {
  secrets = merge(data.aws_secretsmanager_secret.existing, aws_secretsmanager_secret.secrets)
  params  = merge(data.aws_ssm_parameter.existing, aws_ssm_parameter.param)

  secret_arns = [for _key, secret in local.secrets : secret.arn]
  param_arns  = [for _key, param in local.params : param.arn]
  arns        = concat(local.secret_arns, local.param_arns)

  secrets_container_definition = [for key, secret in local.secrets :
    {
      name      = key
      valueFrom = secret.arn
    }
  ]
  params_container_definition = [for key, param in local.params :
    {
      name      = key
      valueFrom = param.arn
    }
  ]
  container_definitions = concat(local.secrets_container_definition, local.params_container_definition)
}
