// S3 bucket to store kops state.
resource "aws_s3_bucket" "kops_state" {
  bucket        = "kops-state-${var.DOMAIN}-${var.ENVIRONMENT}"
  acl           = "private"
  force_destroy = false
}