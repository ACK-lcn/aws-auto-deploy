# 测试环境 S3 桶主配置
# 本配置支持基础安全和可配置功能，所有功能点加详细注释

provider "aws" {
  region = var.aws_region
}

resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name
  force_destroy = var.force_destroy
  tags = var.tags
}

# 公网/私有访问控制
resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id
  block_public_acls       = var.block_public_access
  block_public_policy     = var.block_public_access
  ignore_public_acls      = var.block_public_access
  restrict_public_buckets = var.block_public_access
}

# 版本控制（可选）
resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id
  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Suspended"
  }
}

# 默认加密（可选）
resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  count  = var.enable_encryption ? 1 : 0
  bucket = aws_s3_bucket.this.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = var.sse_algorithm
      kms_master_key_id = var.sse_algorithm == "aws:kms" ? var.kms_key_id : null
    }
  }
}

# 访问日志（可选）
resource "aws_s3_bucket_logging" "this" {
  count  = var.enable_logging ? 1 : 0
  bucket = aws_s3_bucket.this.id
  target_bucket = var.logging_bucket
  target_prefix = var.logging_prefix
}

# 生命周期管理（可选）
resource "aws_s3_bucket_lifecycle_configuration" "this" {
  count  = var.enable_lifecycle ? 1 : 0
  bucket = aws_s3_bucket.this.id
  rule {
    id     = "log"
    status = "Enabled"
    filter {
      prefix = ""
    }
    transition {
      days          = 7
      storage_class = "GLACIER"
    }
    expiration {
      days = 30
    }
  }
}

# 桶策略（公网/私有访问控制）
resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.this.id
  policy = var.public_access ? data.aws_iam_policy_document.public.json : data.aws_iam_policy_document.private.json
}

data "aws_iam_policy_document" "public" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.this.arn}/*"]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    effect = "Allow"
  }
}

data "aws_iam_policy_document" "private" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.this.arn}/*"]
    principals {
      type        = "AWS"
      identifiers = var.allowed_iam_arns
    }
    effect = "Allow"
  }
}

# 安装成功日志输出
resource "null_resource" "install_success" {
  provisioner "local-exec" {
    command = "echo '[S3部署] 测试环境S3桶及相关资源已成功创建！桶名: ${aws_s3_bucket.this.bucket}'"
  }
  triggers = {
    bucket = aws_s3_bucket.this.bucket
  }
  depends_on = [aws_s3_bucket.this]
}

