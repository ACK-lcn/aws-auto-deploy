# EFS自动化部署

## 项目简介
本模块通过Terraform自动化部署AWS EFS文件存储，支持多可用区高可用、可选跨区域复制、自动弹性扩缩容、自动备份等，兼顾性能与成本。

---

## 目录结构
```
efs/
  main.tf
  variables.tf
  outputs.tf
  terraform.tfvars.example
```

---

## 实现功能
- 自动化部署EFS文件系统，支持多可用区高可用（自动为每个子网创建挂载目标）
- 支持EFS自动弹性扩缩容（EFS本身特性，无需手动配置）
- 支持EFS跨区域复制（可选，适合灾备/多地训练）
- 支持EFS自动备份（可选，基于AWS Backup），备份功能待完善ing
- 性能模式、吞吐模式、加密、成本优化等均可灵活配置
- 所有功能均可通过变量文件灵活开关，配置项有详细注释
- 安装成功自动输出日志，便于追踪

---

## 主要参数说明
| 参数名 | 说明 | 示例/建议 |
|--------|------|-----------|
| aws_region | EFS所在区域 | cn-north-1、us-east-1 |
| vpc_id | EFS所在VPC的ID | vpc-xxxxxx |
| subnet_ids | EFS挂载目标子网ID列表 | ["subnet-aaa", "subnet-bbb"] |
| efs_name | EFS名称 | ai-efs |
| performance_mode | 性能模式 | generalPurpose/maxIO |
| throughput_mode | 吞吐模式 | bursting/provisioned |
| provisioned_throughput_in_mibps | 吞吐量（MiB/s） | 1024（provisioned时必填） |
| encrypted | 是否加密 | true |
| enable_backup | 是否启用自动备份 | true/false |
| backup_policy | 备份策略 | AUTOMATIC |
| enable_replication | 是否启用跨区域复制 | true/false |
| replication_destination_region | 目标区域 | us-west-2 |
| replication_destination_kms_key | 目标区域KMS密钥 | 可选 |

---

## 部署方法
1. 进入efs目录：`cd efs`
2. 复制`terraform.tfvars.example`为`terraform.tfvars`，根据实际需求修改参数
3. 初始化与部署：
```sh
terraform init
terraform plan
terraform apply
```

---

## AI大模型场景优化建议
- 性能模式建议选用`maxIO`，吞吐模式建议`provisioned`并合理设置吞吐量
- 建议所有可用区都创建挂载目标，提升高可用性和训练/推理速度
- 生产环境建议开启加密、自动备份、跨区域复制（如需灾备）
- 训练数据量大时，EFS弹性扩缩容可自动应对，无需手动扩容
- 结合Spot实例、Auto Scaling等进一步优化成本

---

## 参考文档
- [AWS EFS官方文档](https://docs.aws.amazon.com/efs/latest/ug/whatisefs.html)
- [EFS多可用区高可用](https://docs.aws.amazon.com/efs/latest/ug/mount-targets.html)
- [EFS跨区域复制](https://docs.aws.amazon.com/efs/latest/ug/efs-replication.html)
- [EFS自动弹性扩缩容](https://docs.aws.amazon.com/efs/latest/ug/performance.html)
- [EFS备份](https://docs.aws.amazon.com/efs/latest/ug/awsbackup.html)