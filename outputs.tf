output "secrets" {
  value       = local.secrets
  description = "Map of secrets, each key is the name, the value is the secret resource"
}

output "secret_version_ids" {
  value       = { for key, secret in aws_secretsmanager_secret_version.secrets : key => secret.version_id }
  description = "Map of secret version IDs, each key is the name, the value is the secret version ID"
}

output "secret_arns" {
  value       = local.secret_arns
  description = "List of ARNs of the secrets - to use in IAM policies"
}

output "param_arns" {
  value       = local.param_arns
  description = "List of ARNs of the SSM parameters - to use in IAM policies"
}

output "arns" {
  value       = local.arns
  description = "List of ARNs of the secrets and SSM Params"
}

output "secrets_container_definition" {
  value       = local.secrets_container_definition
  description = "List of secrets maps in the format: { name = <name>, valueFrom = <arn> } - to use in container definitions"
}

output "params_container_definition" {
  value       = local.params_container_definition
  description = "List of SSM Parameter maps in the format: { name = <name>, valueFrom = <arn> } - to use in container definitions "
}

output "container_definition" {
  value       = local.container_definitions
  description = "List of secrets and SSM Parameter maps in the format: { name = <name>, valueFrom = <arn> } - to use in container definitions"
}

output "secrets_iam_policy_document" {
  value       = try(data.aws_iam_policy_document.secrets_access[0].json, null)
  description = "IAM policy document containing permissions for accessing the defined secrets - to use in the Task Execution role"
}

output "params_iam_policy_document" {
  value       = try(data.aws_iam_policy_document.params_access[0].json, null)
  description = "IAM policy document containing permissions for accessing the defined SSM parameters - to use in the Task Execution role"
}

output "iam_policy_document" {
  value       = try(data.aws_iam_policy_document.access[0].json, null)
  description = "IAM policy document containing permissions for accessing the defined secrets and SSM parameters - to use in the Task Execution role"
}

output "kms_key_arn" {
  value       = data.aws_kms_key.kms_key.arn
  description = "ARN of the KMS key used to encrypt the secret values"
}

output "kms_key_id" {
  value       = data.aws_kms_key.kms_key.key_id
  description = "ID of the KMS key used to encrypt the secret values"
}
