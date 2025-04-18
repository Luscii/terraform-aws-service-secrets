# terraform-aws-service-secrets
Module to handle secrets for AWS (ECS) services

## Example

```terraform
module "service_secrets" {
  source = "./"

  kms_key_id = "<KMS_KEY_ID>"
  secrets = {
    db_pass = {
      value       = "DatabaseP@ssw0rd!"
      description = "Password for the Database"
    }
    use_already_set_secret = {
      value_from_arn = "arn:aws:secretsmanager:<REGION>:<ACCOUNT_ID>:secret:<SECRET_NAME>"
      description    = "Secret that has already been set can also be reused"
    }
  }
}

data "aws_iam_policy_document" "secrets" {
  statement {
    sid       = "GetSecrets"
    effect    = "Allow"
    actions   = [
      "secretsmanager:GetSecretValue"
    ]
    resources = module.service_secrets.arns
  }
  statement {
    sid       = "kmsDecrypt"
    effect    = "Allow"
    actions   = [
      "kms:Decrypt"
    ]
    resources = [
      module.service_secrets.kms_key_arn
    ]
  }
}

module "container_definition" {
  source  = "cloudposse/ecs-container-definition/aws"
  version = "0.61.1"

  container_name = "service"
  container_image = "docker/service-image"

  environment = [
    {
      name  = "ENVIRONMENT",
      value = "production"
    }
  ]
  secrets     = module.service_secrets.container_definition
}
```

## Configuration
<!-- BEGIN_TF_DOCS -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.9 |

### Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.90.0 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_path"></a> [path](#module\_path) | cloudposse/label/null | 0.25.0 |
| <a name="module_secret_path"></a> [secret\_path](#module\_secret\_path) | cloudposse/label/null | 0.25.0 |

### Resources

| Name | Type |
|------|------|
| [aws_secretsmanager_secret.secrets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret_version.secrets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_kms_key.kms_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/kms_key) | data source |
| [aws_secretsmanager_secret.existing](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br/>See description of individual variables for details.<br/>Leave string and numeric variables as `null` to use default value.<br/>Individual variable settings (non-null) override settings in context object,<br/>except for attributes, tags, and additional\_tag\_map, which are merged. | `any` | <pre>{<br/>  "additional_tag_map": {},<br/>  "attributes": [],<br/>  "delimiter": null,<br/>  "descriptor_formats": {},<br/>  "enabled": true,<br/>  "environment": null,<br/>  "id_length_limit": null,<br/>  "label_key_case": null,<br/>  "label_order": [],<br/>  "label_value_case": null,<br/>  "labels_as_tags": [<br/>    "unset"<br/>  ],<br/>  "name": null,<br/>  "namespace": null,<br/>  "regex_replace_chars": null,<br/>  "stage": null,<br/>  "tags": {},<br/>  "tenant": null<br/>}</pre> | no |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | KMS Key identifier to be used to encrypt the secret values in the versions stored in this secret. Can be in any of the formats: Key ID, Key ARN, Alias Name, Alias ARN | `string` | n/a | yes |
| <a name="input_path_delimiter"></a> [path\_delimiter](#input\_path\_delimiter) | Delimiter to use in the path creation | `string` | `"/"` | no |
| <a name="input_path_tags"></a> [path\_tags](#input\_path\_tags) | Additional tags for appending to the context and label tags for the path | `map(string)` | `{}` | no |
| <a name="input_secrets"></a> [secrets](#input\_secrets) | Map of secrets, each key will be the name. When the value is set, a secret is created. Otherwise the arn of existing secret is added to the outputs. | <pre>map(object({<br/>    value          = optional(string)<br/>    description    = optional(string)<br/>    value_from_arn = optional(string)<br/>  }))</pre> | n/a | yes |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_arns"></a> [arns](#output\_arns) | List of ARNs of the secrets - to use in IAM policies |
| <a name="output_container_definition"></a> [container\_definition](#output\_container\_definition) | List of secrets maps in the format: { name = <name>, valueFrom = <arn> } - to use in container definitions |
| <a name="output_kms_key_arn"></a> [kms\_key\_arn](#output\_kms\_key\_arn) | ARN of the KMS key used to encrypt the secret values |
| <a name="output_kms_key_id"></a> [kms\_key\_id](#output\_kms\_key\_id) | ID of the KMS key used to encrypt the secret values |
| <a name="output_secret_version_ids"></a> [secret\_version\_ids](#output\_secret\_version\_ids) | Map of secret version IDs, each key is the name, the value is the secret version ID |
| <a name="output_secrets"></a> [secrets](#output\_secrets) | Map of secrets, each key is the name, the value is the secret resource |
<!-- END_TF_DOCS -->
