# 测试环境 S3 桶输出

output "bucket_name" {
  description = "S3 桶名称"
  value       = aws_s3_bucket.this.bucket
}

output "bucket_arn" {
  description = "S3 桶ARN"
  value       = aws_s3_bucket.this.arn
}
