data "aws_kms_key" "kms_key" {
  key_id = var.kms_key_id
}
