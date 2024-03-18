// 13. S3 bucket
resource "aws_s3_bucket" "wordpress_bucket" {
    bucket = var.bucket_name
    tags = {
        Name = var.bucket_name
    }
}
