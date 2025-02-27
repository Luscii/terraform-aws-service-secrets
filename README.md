# terraform-aws-service-secrets
Module to handle secrets for AWS (ECS) services

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
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.88.0 |

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
| [aws_secretsmanager_secret.existing](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br/>See description of individual variables for details.<br/>Leave string and numeric variables as `null` to use default value.<br/>Individual variable settings (non-null) override settings in context object,<br/>except for attributes, tags, and additional\_tag\_map, which are merged. | `any` | <pre>{<br/>  "additional_tag_map": {},<br/>  "attributes": [],<br/>  "delimiter": null,<br/>  "descriptor_formats": {},<br/>  "enabled": true,<br/>  "environment": null,<br/>  "id_length_limit": null,<br/>  "label_key_case": null,<br/>  "label_order": [],<br/>  "label_value_case": null,<br/>  "labels_as_tags": [<br/>    "unset"<br/>  ],<br/>  "name": null,<br/>  "namespace": null,<br/>  "regex_replace_chars": null,<br/>  "stage": null,<br/>  "tags": {},<br/>  "tenant": null<br/>}</pre> | no |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | ARN or Id of the AWS KMS key to be used to encrypt the secret values in the versions stored in this secret. If you need to reference a CMK in a different account, you can use only the key ARN. | `string` | n/a | yes |
| <a name="input_path_delimiter"></a> [path\_delimiter](#input\_path\_delimiter) | Delimiter to use in the path creation | `string` | `"/"` | no |
| <a name="input_path_tags"></a> [path\_tags](#input\_path\_tags) | Additional tags for appending to the context and label tags for the path | `map(string)` | `{}` | no |
| <a name="input_secrets"></a> [secrets](#input\_secrets) | Map of secrets, each key will be the name. When the value is set, a secret is created. Otherwise the arn of existing secret is added to the outputs. | <pre>map(object({<br/>    value          = optional(string)<br/>    value_from_arn = optional(string)<br/>  }))</pre> | n/a | yes |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_arns"></a> [arns](#output\_arns) | List of ARNs of the secrets - to use in IAM policies |
| <a name="output_container_definition"></a> [container\_definition](#output\_container\_definition) | List of secrets maps in the format: { name = <name>, valueFrom = <arn> } - to use in container definitions |
| <a name="output_secrets"></a> [secrets](#output\_secrets) | Map of secrets, each key is the name, the value is the secret resource |
<!-- END_TF_DOCS -->
