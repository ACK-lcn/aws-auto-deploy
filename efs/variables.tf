# EFS主配置变量定义

variable "aws_region" {
  description = "EFS所在AWS区域，如：cn-north-1、us-east-1"
  type        = string
}

variable "vpc_id" {
  description = "EFS所在VPC的ID"
  type        = string
}

variable "subnet_ids" {
  description = "EFS挂载目标所在子网ID列表，建议为所有可用区的子网，实现高可用"
  type        = list(string)
}

variable "efs_name" {
  description = "EFS文件系统名称"
  type        = string
}

variable "performance_mode" {
  description = "EFS性能模式，推荐AI训练/推理用generalPurpose或maxIO。详见官方文档。"
  type        = string
  default     = "generalPurpose"
}

variable "throughput_mode" {
  description = "EFS吞吐模式，推荐bursting（弹性）或provisioned（固定）。AI大模型建议provisioned。"
  type        = string
  default     = "bursting"
}

variable "provisioned_throughput_in_mibps" {
  description = "吞吐模式为provisioned时的吞吐量（MiB/s），如不需要可留空。"
  type        = number
  default     = null
}

variable "enable_backup" {
  description = "是否启用EFS自动备份（AWS Backup），true为启用，false为关闭。"
  type        = bool
  default     = true
}

variable "enable_replication" {
  description = "是否启用EFS跨区域复制，true为启用，false为关闭。"
  type        = bool
  default     = false
}

variable "replication_destination_region" {
  description = "EFS跨区域复制的目标区域，如us-west-2。仅enable_replication为true时生效。"
  type        = string
  default     = ""
}

variable "replication_destination_kms_key" {
  description = "目标区域EFS的KMS加密密钥ARN（可选）。"
  type        = string
  default     = ""
}

variable "encrypted" {
  description = "是否启用EFS加密，建议开启。"
  type        = bool
  default     = true
}

variable "backup_schedule_expression" {
  description = "EFS备份计划表达式（如cron语法，示例：cron(0 5 * * ? *) 表示每天UTC 5点自动备份）。如不设置则使用AWS Backup默认策略。详见：https://docs.aws.amazon.com/aws-backup/latest/devguide/scheduling.html"
  type        = string
  default     = ""
}
