// 14. IAM access key
resource "aws_iam_access_key" "wordpress_s3_access_key" {
  depends_on = [aws_s3_bucket.wordpress_bucket, aws_iam_policy.wordpress_s3_policy, aws_iam_user.wordpress_s3_user]
  user = aws_iam_user.wordpress_s3_user.name
}

// 15. IAM user
resource "aws_iam_user" "wordpress_s3_user" {
  depends_on = [aws_s3_bucket.wordpress_bucket, aws_iam_policy.wordpress_s3_policy]
  name = var.admin_user
  tags = {
    Name = var.iam_user
  }
}

// 16. IAM policy
resource "aws_iam_policy" "wordpress_s3_policy" {
  name       = "wordpress_s3_policy"
  policy     = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Sid     = "AllAccess",
        Effect  = "Allow",
        Action  = "s3:*",
        Resource = [
          "${aws_s3_bucket.wordpress_bucket.arn}",
          "${aws_s3_bucket.wordpress_bucket.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "wordpress_s3_policy_attachment" {
  depends_on = [aws_iam_user.wordpress_s3_user, aws_iam_policy.wordpress_s3_policy]
  user       = aws_iam_user.wordpress_s3_user.name
  policy_arn = aws_iam_policy.wordpress_s3_policy.arn
}

// 18. IAM policy document
# data "aws_iam_policy_document" "wordpress_s3_policy_document" {
#   depends_on = [aws_s3_bucket.wordpress_bucket]
#   statement {
#     sid = "AllowS3BucketAccess"
#     effect = "Allow"
#     actions = [
#       "s3:*"
#     ]
#     resources = [
#       aws_s3_bucket.wordpress_bucket.arn,
#       "${aws_s3_bucket.wordpress_bucket.arn}/*"
#     ]
#   }
# }
