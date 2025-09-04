module "path" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  context   = var.context
  delimiter = var.path_delimiter
  tags      = var.path_tags
}

module "base_id" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  context          = module.path.context
  delimiter        = ""
  label_value_case = "title"
}
