# S3 监控指标配置（生产环境）
# 通过变量enable_monitoring控制是否启用监控

variable "enable_monitoring" {
  description = "是否启用S3监控指标（true为启用，false为关闭）"
  type        = bool
  default     = true
}

# 参考官方文档：https://docs.aws.amazon.com/AmazonS3/latest/userguide/metrics-dimensions.html
# 重要指标说明见下方注释

resource "aws_cloudwatch_metric_alarm" "s3_4xx_errors" {
  count               = var.enable_monitoring ? 1 : 0
  alarm_name          = "${var.bucket_name}-4xx-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "4xxErrors"
  namespace           = "AWS/S3"
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "S3 4xx错误（客户端错误）次数，通常表示访问异常或权限问题。详见：https://docs.aws.amazon.com/AmazonS3/latest/userguide/metrics-dimensions.html#s3-metrics-errors"
  dimensions = {
    BucketName = var.bucket_name
    StorageType = "AllStorageTypes"
  }
  actions_enabled = false
}

resource "aws_cloudwatch_metric_alarm" "s3_5xx_errors" {
  count               = var.enable_monitoring ? 1 : 0
  alarm_name          = "${var.bucket_name}-5xx-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "5xxErrors"
  namespace           = "AWS/S3"
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "S3 5xx错误（服务端错误）次数，通常表示AWS服务异常。详见：https://docs.aws.amazon.com/AmazonS3/latest/userguide/metrics-dimensions.html#s3-metrics-errors"
  dimensions = {
    BucketName = var.bucket_name
    StorageType = "AllStorageTypes"
  }
  actions_enabled = false
}

resource "aws_cloudwatch_metric_alarm" "s3_number_of_objects" {
  count               = var.enable_monitoring ? 1 : 0
  alarm_name          = "${var.bucket_name}-object-count"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "NumberOfObjects"
  namespace           = "AWS/S3"
  period              = 86400
  statistic           = "Average"
  threshold           = 1000000
  alarm_description   = "S3对象数量，监控桶内对象总数，防止超出预期。详见：https://docs.aws.amazon.com/AmazonS3/latest/userguide/metrics-dimensions.html#s3-metrics-storage"
  dimensions = {
    BucketName = var.bucket_name
    StorageType = "AllStorageTypes"
  }
  actions_enabled = false
}

resource "aws_cloudwatch_metric_alarm" "s3_bucket_size" {
  count               = var.enable_monitoring ? 1 : 0
  alarm_name          = "${var.bucket_name}-bucket-size"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "BucketSizeBytes"
  namespace           = "AWS/S3"
  period              = 86400
  statistic           = "Average"
  threshold           = 107374182400 # 100GB
  alarm_description   = "S3桶总存储空间，监控存储用量，防止费用异常。详见：https://docs.aws.amazon.com/AmazonS3/latest/userguide/metrics-dimensions.html#s3-metrics-storage"
  dimensions = {
    BucketName = var.bucket_name
    StorageType = "StandardStorage"
  }
  actions_enabled = false
} 