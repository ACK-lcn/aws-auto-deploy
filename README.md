# aws-auto-deploy

## 项目简介
本项目通过Terraform自动化部署通用的AWS S3对象存储桶，分别为生产环境和测试环境提供独立的基础设施代码，支持合规、高可用、高稳定性配置，并可通过配置项灵活开启/关闭各项功能。

---

## 注意事项与建议
- 测试环境可根据实际需求灵活配置，但建议保留基础安全措施。
- 所有功能点均可通过变量灵活控制，便于一键切换。

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
## 参考文档：
- [terraform官方文档](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
- [AWS S3官方文档](https://docs.aws.amazon.com/zh_cn/AmazonS3/latest/userguide/Welcome.html)
- [AWS S3 Metrics and dimensions](https://docs.aws.amazon.com/AmazonS3/latest/userguide/metrics-dimensions.html#s3-metrics-storage)

---

## 反思与改进建议
- 功能待完善中，后续可扩展支持更多S3高级特性（如对象锁定、事件通知等）。
- 可集成CI/CD自动化部署与合规检测。
- 欢迎提出建议与反馈。