# Variables Reference

## kms_key_id

| Property | Value |
|----------|-------|
| Type | `string` |
| Default | `null` |
| Required | No (but required when creating secrets or sensitive parameters) |

KMS Key identifier for encrypting secret values. Accepts: Key ID, Key ARN, Alias Name, or Alias ARN.

## secrets

| Property | Value |
|----------|-------|
| Type | `map(object({ value, description, value_from_arn }))` |
| Default | `{}` |
| Sensitive | Yes |

Map of secrets where each key becomes the secret name suffix.

### Secret object fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `value` | `string` | One of value/value_from_arn | The secret value. Creates a new Secrets Manager secret. |
| `description` | `string` | No | Description for the secret |
| `value_from_arn` | `string` | One of value/value_from_arn | ARN of an existing secret to reference |

### Validations
- `value` and `value_from_arn` are mutually exclusive
- `value_from_arn` must match: `arn:aws:secretsmanager:<region>:<account-id>:secret:<name>-<6chars>`

## parameters

| Property | Value |
|----------|-------|
| Type | `map(object({ data_type, description, sensitive, tier, value, value_from_arn }))` |
| Default | `{}` |

Map of SSM parameters where each key becomes the parameter name suffix.

### Parameter object fields

| Field | Type | Default | Required | Description |
|-------|------|---------|----------|-------------|
| `value` | `string` | - | One of value/value_from_arn | The parameter value. Creates a new SSM parameter. |
| `description` | `string` | - | No | Description for the parameter |
| `sensitive` | `bool` | `false` | No | When `true`, uses SecureString type with KMS encryption |
| `tier` | `string` | `"Advanced"` | No | One of: `Standard`, `Advanced`, `Intelligent-Tiering` |
| `data_type` | `string` | `"text"` | No | One of: `text`, `aws:ec2:image`, `aws:ssm:integration` |
| `value_from_arn` | `string` | - | One of value/value_from_arn | ARN of an existing parameter to reference |

### Validations
- `value` and `value_from_arn` are mutually exclusive
- `value_from_arn` must match: `arn:aws:ssm:<region>:<account-id>:parameter/<name>`
- `data_type` must be one of: `text`, `aws:ec2:image`, `aws:ssm:integration`
- `tier` must be one of: `Standard`, `Advanced`, `Intelligent-Tiering`

### Parameter type logic
- `data_type = "aws:ssm:integration"` -> SecureString, no KMS key needed, uses special webhook prefix
- `sensitive = true` -> SecureString with KMS encryption (requires `kms_key_id`)
- Otherwise -> String (no encryption)

## context

| Property | Value |
|----------|-------|
| Type | `any` |
| Required | No |

CloudPosse label context object for naming and tagging. Key fields:

| Field | Purpose |
|-------|---------|
| `namespace` | Organization or project namespace |
| `environment` | Environment name (e.g., `prod`, `staging`) |
| `stage` | Stage within environment |
| `name` | Service/component name |
| `delimiter` | Separator for label components |
| `tags` | Tags to apply to resources |
| `attributes` | Additional attributes appended to the label |

The context generates the path prefix for all secrets and parameters. For example, with `namespace=luscii`, `environment=prod`, `name=api`, the path becomes `/luscii/prod/api/`.

## path_delimiter

| Property | Value |
|----------|-------|
| Type | `string` |
| Default | `"/"` |

Delimiter used in path construction for secret and parameter names.

## path_tags

| Property | Value |
|----------|-------|
| Type | `map(string)` |
| Default | `{}` |

Additional tags appended to the context tags for path label generation.
