# Outputs Reference

## ECS Integration Outputs

These are the primary outputs for wiring into ECS task definitions.

### container_definition
Combined list of secrets and parameters formatted for ECS container definitions.
- Type: `list(object({ name = string, valueFrom = string }))`
- Usage: Pass directly to the `secrets` argument of an ECS container definition module

### secrets_container_definition
List of only secrets in `{ name, valueFrom }` format.

### params_container_definition
List of only parameters in `{ name, valueFrom }` format.

## IAM Policy Outputs

Ready-to-use JSON IAM policy documents for ECS task execution roles.

### iam_policy_document
Combined IAM policy document granting access to all defined secrets and parameters. Includes:
- `secretsmanager:GetSecretValue` for secrets
- `ssm:GetParameter`, `ssm:GetParameters`, `ssm:GetParametersByPath` for parameters
- `kms:Decrypt`, `kms:GenerateDataKey` for encrypted resources

### secrets_iam_policy_document
IAM policy document for secrets access only.

### parameters_iam_policy_document
IAM policy document for parameters access only.

## Resource Metadata Outputs

### secrets
Map of created/referenced secret metadata (excludes actual values).
- Type: `map(object({ arn, id, name, description }))`

### secret_version_ids
Map of secret version IDs.
- Type: `map(string)`

### secret_arns
Flat list of all secret ARNs.

### parameters
Map of created/referenced parameter metadata (excludes actual values).
- Type: `map(object({ arn, id, name, description, type, data_type, version }))`

### parameters_arns
Flat list of all parameter ARNs.

### arns
Combined flat list of all secret and parameter ARNs.

## KMS Key Outputs

### kms_key_arn
ARN of the KMS key, or `null` if no `kms_key_id` was provided.

### kms_key_id
ID of the KMS key, or `null` if no `kms_key_id` was provided.
