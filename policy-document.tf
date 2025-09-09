locals {
  has_secrets = length(var.secrets) > 0
  has_params  = length(var.parameters) > 0
}

data "aws_iam_policy_document" "secrets_access" {
  count = local.has_secrets ? 1 : 0

  statement {
    sid    = join("", [module.base_id.id, "SecretsAccess"])
    effect = "Allow"

    actions = [
      "secretsmanager:GetSecretValue",
    ]

    resources = local.secret_arns
  }

  statement {
    sid    = join("", [module.base_id.id, "SecretsKmsDecrypt"])
    effect = "Allow"

    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey"
    ]

    resources = data.aws_kms_key.secrets[*].arn
  }
}

data "aws_iam_policy_document" "params_access" {
  count = local.has_params ? 1 : 0

  statement {
    sid    = join("", [module.base_id.id, "ParamsAccess"])
    effect = "Allow"

    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:GetParametersByPath"
    ]

    resources = local.param_arns
  }

  dynamic "statement" {
    for_each = length([for k, v in var.parameters : v.sensitive if v.sensitive == true]) > 0 ? { kms = "kms" } : {}

    content {
      sid    = join("", [module.base_id.id, "ParamsKmsDecrypt"])
      effect = "Allow"

      actions = [
        "kms:Decrypt",
        "kms:GenerateDataKey"
      ]

      resources = length(data.aws_kms_key.kms_key) > 0 ? [
        data.aws_kms_key.kms_key[0].arn
      ] : []
    }
  }
}

locals {
  policy_documents = concat(
    data.aws_iam_policy_document.secrets_access[*].json,
    data.aws_iam_policy_document.params_access[*].json
  )
}

data "aws_iam_policy_document" "access" {
  count                     = length(local.policy_documents) > 0 ? 1 : 0
  override_policy_documents = local.policy_documents
}
