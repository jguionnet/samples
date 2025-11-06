output "bucket_name" {
  description = "Name of the created S3 bucket"
  value       = aws_s3_bucket.product_images.bucket
}

output "bucket_arn" {
  description = "ARN of the created S3 bucket"
  value       = aws_s3_bucket.product_images.arn
}

output "bucket_region" {
  description = "Region of the S3 bucket"
  value       = aws_s3_bucket.product_images.region
}

output "iam_role_arn" {
  description = "ARN of the IAM role for product API"
  value       = aws_iam_role.product_api.arn
}

output "iam_role_name" {
  description = "Name of the IAM role"
  value       = aws_iam_role.product_api.name
}

output "iam_policy_arn" {
  description = "ARN of the IAM policy for S3 access"
  value       = aws_iam_policy.s3_access.arn
}
