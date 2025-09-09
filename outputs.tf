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

output "parameters" {
  value       = local.params
  description = "Map of SSM parameters, each key is the name, the value is the parameter resource"
}

output "parameters_arns" {
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

output "parameters_iam_policy_document" {
  value       = try(data.aws_iam_policy_document.params_access[0].json, null)
  description = "IAM policy document containing permissions for accessing the defined SSM parameters - to use in the Task Execution role"
}

output "iam_policy_document" {
  value       = try(data.aws_iam_policy_document.access[0].json, null)
  description = "IAM policy document containing permissions for accessing the defined secrets and SSM parameters - to use in the Task Execution role"
}

output "kms_key_arn" {
  value       = length(data.aws_kms_key.kms_key) > 0 ? data.aws_kms_key.kms_key[0].arn : null
  description = "ARN of the KMS key used to encrypt the secret values, if provided"
}

output "kms_key_id" {
  value       = length(data.aws_kms_key.kms_key) > 0 ? data.aws_kms_key.kms_key[0].key_id : null
  description = "ID of the KMS key used to encrypt the secret values, if provided"
}
