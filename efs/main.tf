# EFS主资源定义，专为AI大模型训练/推理场景优化
# 参考官方文档：https://docs.aws.amazon.com/efs/latest/ug/whatisefs.html

provider "aws" {
  region = var.aws_region
}

# 创建EFS文件系统
resource "aws_efs_file_system" "this" {
  creation_token   = var.efs_name
  encrypted       = var.encrypted
  performance_mode = var.performance_mode
  throughput_mode  = var.throughput_mode
  provisioned_throughput_in_mibps = var.throughput_mode == "provisioned" && var.provisioned_throughput_in_mibps != null ? var.provisioned_throughput_in_mibps : null
  tags = {
    Name = var.efs_name
  }
}

# 为每个子网创建挂载目标，实现多可用区高可用
resource "aws_efs_mount_target" "this" {
  for_each = toset(var.subnet_ids)
  file_system_id  = aws_efs_file_system.this.id
  subnet_id       = each.value
  security_groups = [] # 建议用户根据实际场景配置安全组
}

# 自动弹性扩缩容：EFS本身支持弹性扩缩容，无需手动配置，详见官方文档
# https://docs.aws.amazon.com/efs/latest/ug/performance.html

# 启用EFS备份（AWS Backup）
resource "aws_efs_backup_policy" "this" {
  count = var.enable_backup ? 1 : 0
  file_system_id = aws_efs_file_system.this.id
  backup_policy {
    status = var.backup_policy
  }
}

# 跨区域复制（可选）
resource "aws_efs_replication_configuration" "this" {
  count = var.enable_replication ? 1 : 0
  source_file_system_id = aws_efs_file_system.this.id
  destination {
    region = var.replication_destination_region
    kms_key_id = var.replication_destination_kms_key != "" ? var.replication_destination_kms_key : null
  }
}

# 若用户自定义了备份计划，则自动创建AWS Backup计划和备份资源
resource "aws_backup_vault" "efs" {
  count = var.enable_backup && var.backup_schedule_expression != "" ? 1 : 0
  name  = "efs-backup-vault-${var.efs_name}"
}

resource "aws_backup_plan" "efs" {
  count = var.enable_backup && var.backup_schedule_expression != "" ? 1 : 0
  name  = "efs-backup-plan-${var.efs_name}"
  rule {
    rule_name         = "efs-backup-rule"
    target_vault_name = aws_backup_vault.efs[0].name
    schedule          = var.backup_schedule_expression
    lifecycle {
      delete_after = 30 # 备份保留30天，可根据需要调整
    }
    recovery_point_tags = {
      Name = var.efs_name
    }
  }
}

resource "aws_backup_selection" "efs" {
  count = var.enable_backup && var.backup_schedule_expression != "" ? 1 : 0
  iam_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/service-role/AWSBackupDefaultServiceRole" # 需确保此角色存在
  name         = "efs-backup-selection"
  plan_id      = aws_backup_plan.efs[0].id
  resources    = [aws_efs_file_system.this.arn]
}

data "aws_caller_identity" "current" {}

# 安装成功日志输出
resource "null_resource" "install_success" {
  provisioner "local-exec" {
    command = "echo '[EFS部署] EFS及相关资源已成功创建！文件系统ID: ${aws_efs_file_system.this.id}'"
  }
  triggers = {
    fsid = aws_efs_file_system.this.id
  }
  depends_on = [aws_efs_file_system.this]
}
