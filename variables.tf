variable "context" {
  type = any
  default = {
    enabled             = true
    namespace           = null
    tenant              = null
    environment         = null
    stage               = null
    name                = null
    delimiter           = null
    attributes          = []
    tags                = {}
    additional_tag_map  = {}
    regex_replace_chars = null
    label_order         = []
    id_length_limit     = null
    label_key_case      = null
    label_value_case    = null
    descriptor_formats  = {}
    # Note: we have to use [] instead of null for unset lists due to
    # https://github.com/hashicorp/terraform/issues/28137
    # which was not fixed until Terraform 1.0.0,
    # but we want the default to be all the labels in `label_order`
    # and we want users to be able to prevent all tag generation
    # by setting `labels_as_tags` to `[]`, so we need
    # a different sentinel to indicate "default"
    labels_as_tags = ["unset"]
  }
  description = <<-EOT
    Single object for setting entire context at once.
    See description of individual variables for details.
    Leave string and numeric variables as `null` to use default value.
    Individual variable settings (non-null) override settings in context object,
    except for attributes, tags, and additional_tag_map, which are merged.
  EOT

  validation {
    condition     = lookup(var.context, "label_key_case", null) == null ? true : contains(["lower", "title", "upper"], var.context["label_key_case"])
    error_message = "Allowed values: `lower`, `title`, `upper`."
  }

  validation {
    condition     = lookup(var.context, "label_value_case", null) == null ? true : contains(["lower", "title", "upper", "none"], var.context["label_value_case"])
    error_message = "Allowed values: `lower`, `title`, `upper`, `none`."
  }
}

variable "path_delimiter" {
  type        = string
  description = "Delimiter to use in the path creation"
  default     = "/"
}

variable "kms_key_id" {
  type        = string
  description = "KMS Key identifier to be used to encrypt the secret values in the versions stored in this secret. Can be in any of the formats: Key ID, Key ARN, Alias Name, Alias ARN"
}

variable "secrets" {
  type = map(object({
    value          = optional(string)
    description    = optional(string)
    value_from_arn = optional(string)
  }))
  sensitive   = true
  description = "Map of secrets, each key will be the name. When the value is set, a secret is created. Otherwise the arn of existing secret is added to the outputs."

  validation {
    condition = alltrue([
      for key, value in var.secrets : contains(keys(value), "value") || contains(keys(value), "value_from_arn")
    ])
    error_message = "value or value_from_arn must be set for each secret"
  }
  validation {
    condition = anytrue([
      for key, value in var.secrets : value.value != null && value.value_from_arn != null ? false : true
    ])
    error_message = "value and value_from_arn cannot be set at the same time"
  }
}

variable "path_tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags for appending to the context and label tags for the path"
}

variable "parameters" {
  type = map(
    object({
      data_type      = optional(string, "text")
      description    = optional(string)
      sensitive      = optional(bool, false)
      tier           = optional(string, "Advanced")
      value          = optional(string)
      value_from_arn = optional(string)
    })
  )
}
