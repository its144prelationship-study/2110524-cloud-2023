// 13. S3 bucket
resource "aws_s3_bucket" "wordpress_bucket" {
    bucket = var.bucket_name
    tags = {
        Name = var.bucket_name
        Environment = "Dev"
    }
}

resource "aws_s3_bucket_public_access_block" "wordpress_bucket_access_block" {
    bucket = aws_s3_bucket.wordpress_bucket.bucket
    block_public_acls = false
    block_public_policy = false
    ignore_public_acls = false
    restrict_public_buckets = false
}

resource "aws_s3_bucket_ownership_controls" "wordpress_bucket_ownership_controls" {
    bucket = aws_s3_bucket.wordpress_bucket.bucket
    rule {
        object_ownership = "BucketOwnerPreferred"
    }
}
