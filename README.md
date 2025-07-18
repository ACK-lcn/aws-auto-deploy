# aws-auto-deploy

## 项目简介
本项目通过Terraform自动化部署通用的AWS S3对象存储桶，分别为生产环境和测试环境提供独立的基础设施代码，支持合规、高可用、高稳定性配置，并可通过配置项灵活开启/关闭各项功能。

---

## 目录结构
```
aws-auto-deploy/
  s3/
    prod/    # 生产环境Terraform代码
    test/    # 测试环境Terraform代码
  README.md
```

---

## 实现功能
- 自动化部署生产级合规、高可用、高稳定性的S3对象存储桶
- 支持通过配置项灵活开启/关闭如下功能：
  - 版本控制（Versioning）
  - 默认加密（SSE-S3或SSE-KMS）
  - 访问日志（Server Access Logging）
  - 生命周期管理（Lifecycle Policy）
  - 跨区复制（Cross-Region Replication，生产环境可选）
  - 公网访问/私有访问切换（可配置，支持公网或仅限指定IAM用户/角色访问）
  - 阻止公有访问（Block Public Access）
  - 标签（Tags）
  - S3重要监控指标（可选，支持通过变量enable_monitoring控制是否启用）
    - 4xxErrors：客户端错误次数，反映访问异常或权限问题
    - 5xxErrors：服务端错误次数，反映AWS服务异常
    - NumberOfObjects：桶内对象总数，防止超出预期
    - BucketSizeBytes：桶总存储空间，防止费用异常
    - 详细指标说明与官方文档：https://docs.aws.amazon.com/AmazonS3/latest/userguide/metrics-dimensions.html
- 生产环境与测试环境代码完全独立，互不影响
- 所有主要功能点均有详细注释，便于理解和维护

---

## 使用方法
### 前置条件：
- 安装Terraform

### 1. 进入对应环境目录
- 生产环境：`cd s3/prod`
- 测试环境：`cd s3/test`

### 2. 配置变量
- 复制`terraform.tfvars.example`为`terraform.tfvars`，根据实际需求修改参数

### 3. 初始化与部署
```sh
terraform init
terraform plan
terraform apply
```

---

## 主要参数说明
| 参数名                | 说明                                   | 生产环境默认 | 测试环境默认 |
|----------------------|----------------------------------------|--------------|--------------|
| aws_region           | AWS区域                                 | 必填         | 必填         |
| bucket_name          | S3桶名称                                | 必填         | 必填         |
| force_destroy        | 是否允许强制销毁桶（删除所有对象）      | false        | true         |
| tags                 | 资源标签                                | {env="prod"}| {env="test"}|
| block_public_access  | 是否阻止公有访问（true为私有）          | true         | false        |
| public_access        | 是否允许公网访问（true为公网）          | false        | true         |
| allowed_iam_arns     | 允许访问的IAM用户/角色ARN列表（私有模式）| []           | []           |
| enable_versioning    | 是否开启版本控制                        | true         | false        |
| enable_encryption    | 是否开启加密                            | true         | false        |
| sse_algorithm        | 加密算法（aws:kms或AES256）             | AES256       | AES256       |
| kms_key_id           | KMS密钥ID（仅sse_algorithm为aws:kms时） | ""          | ""          |
| enable_logging       | 是否开启访问日志                        | true         | false        |
| logging_bucket       | 日志目标桶名称                          | 必填         | ""          |
| logging_prefix       | 日志前缀                                | logs/        | logs/        |
| enable_lifecycle     | 是否开启生命周期管理                    | true         | false        |
| enable_replication   | 是否开启跨区复制                        | false        | -            |
| replication_role_arn | 复制角色ARN                             | ""          | -            |
| replication_dest_arn | 复制目标桶ARN                           | ""          | -            |
| enable_monitoring   | 是否启用S3监控指标（true为启用，false为关闭） | true         | false        |

---

## 返回值说明
- `bucket_name`：S3桶名称
- `bucket_arn`：S3桶ARN

---

## 典型场景举例
- **生产环境**：强制阻止公有访问、开启加密、版本控制、日志、生命周期管理，支持合规与高可用。
- **测试环境**：可灵活关闭部分功能，节省成本，支持公网访问测试。

---

## 注意事项与建议
- 生产环境建议始终开启加密、版本控制、阻止公有访问等合规项。
- 测试环境可根据实际需求灵活配置，但建议保留基础安全措施。
- 若需跨区复制，需提前配置好目标桶和复制角色。
- 所有功能点均可通过变量灵活控制，便于一键切换。
- 本项目暂时仅用于快速搭建S3基础设施，暂时请勿用于对已有S3对象的管理，此功能后期完善。
- 数据无价，暂不支持对已有数据的S3对象存储进行删除操作，望理解与支持。

---


## S3监控指标说明
- 4xxErrors：客户端错误次数，通常表示访问异常或权限问题。详见[官方文档](https://docs.aws.amazon.com/AmazonS3/latest/userguide/metrics-dimensions.html#s3-metrics-errors)
- 5xxErrors：服务端错误次数，通常表示AWS服务异常。详见[官方文档](https://docs.aws.amazon.com/AmazonS3/latest/userguide/metrics-dimensions.html#s3-metrics-errors)
- NumberOfObjects：桶内对象总数，监控数据量，防止超出预期。详见[官方文档](https://docs.aws.amazon.com/AmazonS3/latest/userguide/metrics-dimensions.html#s3-metrics-storage)
- BucketSizeBytes：桶总存储空间，监控存储用量，防止费用异常。详见[官方文档](https://docs.aws.amazon.com/AmazonS3/latest/userguide/metrics-dimensions.html#s3-metrics-storage)

> 监控功能可通过变量`enable_monitoring`灵活开启/关闭，默认生产环境开启，测试环境关闭。
如需关闭监控功能，只需在`terraform.tfvars`中设置`enable_monitoring = false`。

---

---
## 参考文档：
- [terraform官方文档](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
- [AWS S3官方文档](https://docs.aws.amazon.com/zh_cn/AmazonS3/latest/userguide/Welcome.html)
- [AWS S3 Metrics and dimensions](https://docs.aws.amazon.com/AmazonS3/latest/userguide/metrics-dimensions.html#s3-metrics-storage)

---

## 反思与改进建议
- 功能待完善中，后续可扩展支持更多S3高级特性（如对象锁定、事件通知等）。
- 可集成CI/CD自动化部署与合规检测。
- 欢迎提出建议与反馈。