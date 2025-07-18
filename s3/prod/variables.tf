# 生产环境 S3 桶变量定义

variable "aws_region" {
  description = "AWS 区域"
  type        = string
}

variable "bucket_name" {
  description = "S3 桶名称"
  type        = string
}

variable "force_destroy" {
  description = "是否允许强制销毁桶（删除所有对象）"
  type        = bool
  default     = false
}

variable "tags" {
  description = "资源标签"
  type        = map(string)
  default     = {}
}

variable "block_public_access" {
  description = "是否阻止公有访问（true为私有，false为允许公网访问）"
  type        = bool
  default     = true
}

variable "public_access" {
  description = "是否允许公网访问（true为公网，false为私有）"
  type        = bool
  default     = false
}

variable "allowed_iam_arns" {
  description = "允许访问的IAM用户/角色ARN列表（私有模式下生效）"
  type        = list(string)
  default     = []
}

variable "enable_versioning" {
  description = "是否开启版本控制"
  type        = bool
  default     = true
}

variable "enable_encryption" {
  description = "是否开启加密"
  type        = bool
  default     = true
}

variable "sse_algorithm" {
  description = "加密算法（aws:kms 或 AES256）"
  type        = string
  default     = "AES256"
}

variable "kms_key_id" {
  description = "KMS密钥ID（仅sse_algorithm为aws:kms时生效）"
  type        = string
  default     = ""
}

variable "enable_logging" {
  description = "是否开启访问日志"
  type        = bool
  default     = true
}

variable "logging_bucket" {
  description = "日志目标桶名称"
  type        = string
  default     = ""
}

variable "logging_prefix" {
  description = "日志前缀"
  type        = string
  default     = "logs/"
}

variable "enable_lifecycle" {
  description = "是否开启生命周期管理"
  type        = bool
  default     = true
}

variable "enable_replication" {
  description = "是否开启跨区复制"
  type        = bool
  default     = false
}

variable "replication_role_arn" {
  description = "复制角色ARN"
  type        = string
  default     = ""
}

variable "replication_dest_arn" {
  description = "复制目标桶ARN"
  type        = string
  default     = ""
}
