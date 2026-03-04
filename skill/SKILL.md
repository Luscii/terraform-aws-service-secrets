---
name: using-service-secrets
description: 'Guides usage of the terraform-aws-service-secrets module for managing AWS Secrets Manager secrets and SSM Parameters consumed by ECS services. Use when asked to "add a secret", "add a parameter", "configure secrets", "use service-secrets module", "ECS secrets", "SSM parameters", or working with this Terraform module.'
---

# Using the service-secrets Module

Manages AWS Secrets Manager secrets and SSM Parameters for ECS services, with automatic IAM policy generation and ECS container definition output.

## Key Concepts

- **Secrets**: Stored in AWS Secrets Manager, always encrypted with KMS
- **Parameters**: Stored in AWS SSM Parameter Store, optionally encrypted (SecureString) or plain (String)
- **Dual-mode**: Each secret/parameter can be **created** (provide `value`) or **referenced** (provide `value_from_arn`)
- **Outputs**: The module produces ready-to-use IAM policies and ECS container definition fragments

## Usage Workflow

Copy and track:
```
Progress:
- [ ] Step 1: Configure module source and context
- [ ] Step 2: Set up KMS key (required for secrets, required for sensitive parameters)
- [ ] Step 3: Define secrets and/or parameters
- [ ] Step 4: Wire outputs to ECS task definition and execution role
- [ ] Step 5: Validate with terraform plan
```

### Step 1: Configure Module Source and Context

```hcl
module "service_secrets" {
  source = "github.com/Luscii/terraform-aws-service-secrets?ref=<version>"

  context = module.this.context  # CloudPosse label context
}
```

The `context` variable drives naming and tagging via CloudPosse label modules. The generated path becomes the prefix for all secret and parameter names (e.g., `/<namespace>/<environment>/<name>/<secret-key>`).

### Step 2: Set Up KMS Key

```hcl
module "service_secrets" {
  # ...
  kms_key_id = aws_kms_key.secrets.id  # or alias, ARN
}
```

**Required when**: creating secrets or sensitive (SecureString) parameters.
**Not required when**: only creating non-sensitive (String) parameters or only referencing existing resources.

### Step 3: Define Secrets and Parameters

**Creating new secrets:**
```hcl
secrets = {
  db_password = {
    value       = var.db_password
    description = "Database password"
  }
  api_key = {
    value       = var.api_key
    description = "Third-party API key"
  }
}
```

**Referencing existing secrets:**
```hcl
secrets = {
  shared_secret = {
    value_from_arn = "arn:aws:secretsmanager:eu-west-1:123456789012:secret:shared-abc123"
    description    = "Secret managed elsewhere"
  }
}
```

**Creating parameters (non-sensitive):**
```hcl
parameters = {
  log_level = {
    value       = "info"
    description = "Application log level"
  }
}
```

**Creating sensitive parameters (SecureString with KMS):**
```hcl
parameters = {
  connection_string = {
    value       = var.connection_string
    sensitive   = true
    description = "Database connection string"
  }
}
```

**Referencing existing parameters:**
```hcl
parameters = {
  shared_config = {
    value_from_arn = "arn:aws:ssm:eu-west-1:123456789012:parameter/shared/config"
    description    = "Shared configuration parameter"
  }
}
```

For full variable details, see [references/variables.md](references/variables.md).

### Step 4: Wire Outputs to ECS

**Attach IAM policy to the ECS task execution role:**
```hcl
resource "aws_iam_role_policy" "secrets" {
  name   = "service-secrets"
  role   = aws_iam_role.execution.id
  policy = module.service_secrets.iam_policy_document
}
```

**Pass secrets to ECS container definition:**
```hcl
module "container_definition" {
  source  = "cloudposse/ecs-container-definition/aws"
  version = "0.61.1"

  container_name  = "app"
  container_image = "123456789012.dkr.ecr.eu-west-1.amazonaws.com/app:latest"

  secrets = module.service_secrets.container_definition
}
```

The `container_definition` output is a list of `{ name, valueFrom }` maps where `name` is the map key (uppercased by ECS as environment variable name) and `valueFrom` is the ARN.

For all available outputs, see [references/outputs.md](references/outputs.md).

### Step 5: Validate

```bash
terraform plan
```

Check that:
- Secrets and parameters are created with correct names/paths
- IAM policy grants `secretsmanager:GetSecretValue` and/or `ssm:GetParameter*`
- KMS decrypt permissions are included when using encrypted values

## Important Rules

1. **`value` and `value_from_arn` are mutually exclusive** - set one or the other per entry, never both
2. **`kms_key_id` is required** when creating secrets or sensitive parameters - the module will fail with a precondition error otherwise
3. **ARN format validation** is strict:
   - Secrets: `arn:aws:secretsmanager:<region>:<account>:secret:<name>-<6chars>`
   - Parameters: `arn:aws:ssm:<region>:<account>:parameter/<name>`
4. **Parameter tier** defaults to `Advanced` - use `Standard` only if you don't need values > 4KB
5. **Sensitive parameters** (`sensitive = true`) use SecureString type and require KMS

## Common Patterns

### Secrets-only (no parameters)
```hcl
module "service_secrets" {
  source     = "github.com/Luscii/terraform-aws-service-secrets?ref=<version>"
  context    = module.this.context
  kms_key_id = aws_kms_key.secrets.id

  secrets = {
    db_pass = { value = var.db_password }
  }
}
```

### Parameters-only (non-sensitive)
```hcl
module "service_secrets" {
  source  = "github.com/Luscii/terraform-aws-service-secrets?ref=<version>"
  context = module.this.context

  parameters = {
    log_level = { value = "info" }
    region    = { value = "eu-west-1" }
  }
}
# No kms_key_id needed for non-sensitive parameters
```

### Mixed: new + existing
```hcl
module "service_secrets" {
  source     = "github.com/Luscii/terraform-aws-service-secrets?ref=<version>"
  context    = module.this.context
  kms_key_id = aws_kms_key.secrets.id

  secrets = {
    new_secret      = { value = var.secret_value }
    existing_secret = { value_from_arn = "arn:aws:secretsmanager:..." }
  }

  parameters = {
    new_param      = { value = "config-value" }
    existing_param = { value_from_arn = "arn:aws:ssm:..." }
  }
}
```

## Troubleshooting

| Problem | Cause | Solution |
|---------|-------|----------|
| Precondition failed: KMS key required | Creating SecureString param without `kms_key_id` | Set `kms_key_id` or change `sensitive = false` |
| ARN validation error | `value_from_arn` doesn't match expected format | Check ARN format (secrets need 6-char suffix) |
| Both value and value_from_arn set | Mutually exclusive fields | Use only one per entry |
| Empty IAM policy output | No secrets or parameters defined | Add at least one secret or parameter |
