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
  parameters = {
    param = {
      value = "foo"
      description = "System parameter"
    },
    set_param = {
      value_from_arn = "arn:aws:ssm:region:account-id:parameter/parameter-name"
      description = "Parameter that has already been set can also be reused"
    }
  }
}

resource "aws_iam_role_policy" "execution" {
  name = "execution-role"
  role = "{{ExecutionRoleId}}"
  policy = module.service_secrets.iam_policy_document
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
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.12.0 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_base_id"></a> [base\_id](#module\_base\_id) | cloudposse/label/null | 0.25.0 |
| <a name="module_param_path"></a> [param\_path](#module\_param\_path) | cloudposse/label/null | 0.25.0 |
| <a name="module_path"></a> [path](#module\_path) | cloudposse/label/null | 0.25.0 |
| <a name="module_secret_path"></a> [secret\_path](#module\_secret\_path) | cloudposse/label/null | 0.25.0 |

### Resources

| Name | Type |
|------|------|
| [aws_secretsmanager_secret.secrets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret_version.secrets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_ssm_parameter.param](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_iam_policy_document.access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.params_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.secrets_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_kms_key.kms_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/kms_key) | data source |
| [aws_kms_key.secrets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/kms_key) | data source |
| [aws_secretsmanager_secret.existing](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret) | data source |
| [aws_ssm_parameter.existing](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br/>See description of individual variables for details.<br/>Leave string and numeric variables as `null` to use default value.<br/>Individual variable settings (non-null) override settings in context object,<br/>except for attributes, tags, and additional\_tag\_map, which are merged. | `any` | <pre>{<br/>  "additional_tag_map": {},<br/>  "attributes": [],<br/>  "delimiter": null,<br/>  "descriptor_formats": {},<br/>  "enabled": true,<br/>  "environment": null,<br/>  "id_length_limit": null,<br/>  "label_key_case": null,<br/>  "label_order": [],<br/>  "label_value_case": null,<br/>  "labels_as_tags": [<br/>    "unset"<br/>  ],<br/>  "name": null,<br/>  "namespace": null,<br/>  "regex_replace_chars": null,<br/>  "stage": null,<br/>  "tags": {},<br/>  "tenant": null<br/>}</pre> | no |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | KMS Key identifier to be used to encrypt the secret values in the versions stored in this secret. Can be in any of the formats: Key ID, Key ARN, Alias Name, Alias ARN | `string` | `null` | no |
| <a name="input_parameters"></a> [parameters](#input\_parameters) | Map of parameters, each key will be the name. When the value is set, a parameter is created. Otherwise the arn of existing parameter is added to the outputs. | <pre>map(<br/>    object({<br/>      data_type      = optional(string, "text")<br/>      description    = optional(string)<br/>      sensitive      = optional(bool, false)<br/>      tier           = optional(string, "Advanced")<br/>      value          = optional(string)<br/>      value_from_arn = optional(string)<br/>    })<br/>  )</pre> | `{}` | no |
| <a name="input_path_delimiter"></a> [path\_delimiter](#input\_path\_delimiter) | Delimiter to use in the path creation | `string` | `"/"` | no |
| <a name="input_path_tags"></a> [path\_tags](#input\_path\_tags) | Additional tags for appending to the context and label tags for the path | `map(string)` | `{}` | no |
| <a name="input_secrets"></a> [secrets](#input\_secrets) | Map of secrets, each key will be the name. When the value is set, a secret is created. Otherwise the arn of existing secret is added to the outputs. | <pre>map(object({<br/>    value          = optional(string)<br/>    description    = optional(string)<br/>    value_from_arn = optional(string)<br/>  }))</pre> | `{}` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_arns"></a> [arns](#output\_arns) | List of ARNs of the secrets and SSM Params |
| <a name="output_container_definition"></a> [container\_definition](#output\_container\_definition) | List of secrets and SSM Parameter maps in the format: { name = <name>, valueFrom = <arn> } - to use in container definitions |
| <a name="output_iam_policy_document"></a> [iam\_policy\_document](#output\_iam\_policy\_document) | IAM policy document containing permissions for accessing the defined secrets and SSM parameters - to use in the Task Execution role |
| <a name="output_kms_key_arn"></a> [kms\_key\_arn](#output\_kms\_key\_arn) | ARN of the KMS key used to encrypt the secret values, if provided |
| <a name="output_kms_key_id"></a> [kms\_key\_id](#output\_kms\_key\_id) | ID of the KMS key used to encrypt the secret values, if provided |
| <a name="output_parameters"></a> [parameters](#output\_parameters) | Map of SSM parameters, each key is the name, the value is the parameter resource metadata (excluding parameter values) |
| <a name="output_parameters_arns"></a> [parameters\_arns](#output\_parameters\_arns) | List of ARNs of the SSM parameters - to use in IAM policies |
| <a name="output_parameters_iam_policy_document"></a> [parameters\_iam\_policy\_document](#output\_parameters\_iam\_policy\_document) | IAM policy document containing permissions for accessing the defined SSM parameters - to use in the Task Execution role |
| <a name="output_params_container_definition"></a> [params\_container\_definition](#output\_params\_container\_definition) | List of SSM Parameter maps in the format: { name = <name>, valueFrom = <arn> } - to use in container definitions |
| <a name="output_secret_arns"></a> [secret\_arns](#output\_secret\_arns) | List of ARNs of the secrets - to use in IAM policies |
| <a name="output_secret_version_ids"></a> [secret\_version\_ids](#output\_secret\_version\_ids) | Map of secret version IDs, each key is the name, the value is the secret version ID |
| <a name="output_secrets"></a> [secrets](#output\_secrets) | Map of secrets, each key is the name, the value is the secret resource metadata (excluding secret values) |
| <a name="output_secrets_container_definition"></a> [secrets\_container\_definition](#output\_secrets\_container\_definition) | List of secrets maps in the format: { name = <name>, valueFrom = <arn> } - to use in container definitions |
| <a name="output_secrets_iam_policy_document"></a> [secrets\_iam\_policy\_document](#output\_secrets\_iam\_policy\_document) | IAM policy document containing permissions for accessing the defined secrets - to use in the Task Execution role |
<!-- END_TF_DOCS -->
