// 14. IAM access key
resource "aws_iam_access_key" "wordpress_s3_access_key" {
  depends_on = [aws_s3_bucket.wordpress_bucket, aws_iam_policy.wordpress_s3_policy, aws_iam_user.wordpress_s3_user]
  user = aws_iam_user.wordpress_s3_user.name
}

// 15. IAM user
resource "aws_iam_user" "wordpress_s3_user" {
  depends_on = [aws_s3_bucket.wordpress_bucket, aws_iam_policy.wordpress_s3_policy]
  name = var.admin_user
  permissions_boundary = aws_iam_policy.wordpress_s3_policy.arn
  tags = {
    Name = var.iam_user
  }
}

// 16. IAM policy
resource "aws_iam_policy" "wordpress_s3_policy" {
  depends_on = [data.aws_iam_policy_document.wordpress_s3_policy_document]
  name = "wordpress_s3_policy"
  policy = data.aws_iam_policy_document.wordpress_s3_policy_document.json
}

// 18. IAM policy document
data "aws_iam_policy_document" "wordpress_s3_policy_document" {
  depends_on = [aws_s3_bucket.wordpress_bucket]
  statement {
    actions = [
      "s3:ListBucket",
      "s3:DeleteObject",
      "s3:GetObject",
      "s3:GetObjectAcl",
      "s3:PutObject",
      "s3:PutObjectAcl"
    ]
    resources = [
      aws_s3_bucket.wordpress_bucket.arn,
      "${aws_s3_bucket.wordpress_bucket.arn}/*"
    ]
  }
}
