output "s3_bucket_name" {
  description = "Nome do bucket S3"
  value       = aws_s3_bucket.process_bucket.bucket
}

output "s3_bucket_arn" {
  description = "ARN do bucket S3"
  value       = aws_s3_bucket.process_bucket.arn
}