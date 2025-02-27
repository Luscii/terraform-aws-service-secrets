module "path" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  context   = var.context
  delimiter = var.path_delimiter
  tags      = var.path_tags
}
