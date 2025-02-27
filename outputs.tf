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

output "arns" {
  value       = local.secret_arns
  description = "List of ARNs of the secrets - to use in IAM policies"
}

output "container_definition" {
  value       = local.secrets_container_definition
  description = "List of secrets maps in the format: { name = <name>, valueFrom = <arn> } - to use in container definitions"
}
