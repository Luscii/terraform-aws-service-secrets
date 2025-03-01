locals {
  secrets = merge(data.aws_secretsmanager_secret.existing, aws_secretsmanager_secret.secrets)

  secret_arns = [for _key, secret in local.secrets : secret.arn]
  secrets_container_definition = [for key, secret in local.secrets :
    {
      name      = key
      valueFrom = secret.arn
    }
  ]
}

output "secrets" {
  value       = local.secrets
  description = "Map of secrets, each key is the name, the value is the secret resource"
}

output "secret_version_ids" {
  value       = { for key, secret in aws_secretsmanager_secret_version.secrets : key => secret.version_id }
  description = "Map of secret version IDs, each key is the name, the value is the secret version ID"
}

output "arns" {
  value       = local.secret_arns
  description = "List of ARNs of the secrets - to use in IAM policies"
}

output "container_definition" {
  value       = local.secrets_container_definition
  description = "List of secrets maps in the format: { name = <name>, valueFrom = <arn> } - to use in container definitions"
}

output "kms_key_arn" {
  value       = data.aws_kms_key.kms_key.arn
  description = "ARN of the KMS key used to encrypt the secret values"
}

output "kms_key_id" {
  value       = data.aws_kms_key.kms_key.key_id
  description = "ID of the KMS key used to encrypt the secret values"
}
