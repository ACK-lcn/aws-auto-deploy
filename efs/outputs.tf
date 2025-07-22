output "efs_id" {
  description = "EFS文件系统ID"
  value       = aws_efs_file_system.this.id
}

output "efs_dns_name" {
  description = "EFS挂载DNS名称"
  value       = aws_efs_file_system.this.dns_name
}

output "efs_arn" {
  description = "EFS文件系统ARN"
  value       = aws_efs_file_system.this.arn
}
