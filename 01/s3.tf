resource "aws_s3_bucket" "wordpress" {
  bucket        = var.s3_bucket_name
  force_destroy = true

  tags = local.tags
}

resource "aws_s3_bucket_acl" "wordpress" {
  bucket = aws_s3_bucket.wordpress.id
  acl    = "private"
}