# AWS CI/CD Workflow - Golang 示例项目

这是一个用于学习和实践AWS CI/CD工作流的Golang示例项目。项目展示了如何使用GitHub Actions和AWS CodeBuild构建和部署容器化的Go应用到AWS ECS。

## 📋 项目概述

本项目包含：
- ✅ 简单的Golang Web应用（HTTP服务器）
- ✅ 完整的单元测试
- ✅ Docker容器化配置
- ✅ GitHub Actions CI/CD流水线
- ✅ AWS CodeBuild配置
- ✅ AWS ECS部署配置
- ✅ Terraform基础设施即代码
- ✅ 安全扫描集成

## 🏗️ 项目结构

```
.
├── main.go                    # 主应用程序
├── main_test.go              # 单元测试
├── go.mod                    # Go模块文件
├── Dockerfile                # Docker镜像配置
├── .dockerignore            # Docker忽略文件
├── buildspec.yml            # AWS CodeBuild配置
├── appspec.yml              # AWS CodeDeploy配置
├── .github/
│   └── workflows/
│       └── deploy.yml       # GitHub Actions工作流
├── aws/
│   ├── iam-policy.json      # IAM策略文档
│   ├── setup-infrastructure.sh  # 基础设施设置脚本
│   └── setup-ecs-task.sh    # ECS任务定义脚本
└── terraform/
    └── main.tf              # Terraform配置
```

## 🚀 快速开始

### 本地开发

1. **克隆仓库**
```bash
git clone https://github.com/yige666s/aws_cicd_workflow.git
cd aws_cicd_workflow
```

2. **运行应用**
```bash
go run main.go
```

3. **访问应用**
打开浏览器访问: http://localhost:8080

4. **运行测试**
```bash
go test -v ./...
```

### Docker构建

1. **构建Docker镜像**
```bash
docker build -t aws-cicd-app .
```

2. **运行Docker容器**
```bash
docker run -p 8080:8080 aws-cicd-app
```

## ☁️ AWS部署设置

### 前置要求

- AWS账户
- AWS CLI已配置
- 具有适当权限的IAM用户
- Docker已安装

### 方法1: 使用Shell脚本

1. **设置AWS基础设施**
```bash
chmod +x aws/setup-infrastructure.sh
./aws/setup-infrastructure.sh
```

2. **创建ECS任务定义**
```bash
chmod +x aws/setup-ecs-task.sh
./aws/setup-ecs-task.sh
```

### 方法2: 使用Terraform

1. **初始化Terraform**
```bash
cd terraform
terraform init
```

2. **查看执行计划**
```bash
terraform plan
```

3. **应用配置**
```bash
terraform apply
```

### 方法3: 使用AWS CodeBuild

1. **在AWS Console中创建CodeBuild项目**
   - 源: 连接到GitHub仓库
   - 环境: 使用标准Amazon Linux 2镜像
   - Buildspec: 使用仓库中的buildspec.yml

2. **配置环境变量**
   - `AWS_ACCOUNT_ID`: 你的AWS账户ID
   - `AWS_DEFAULT_REGION`: 你的AWS区域
   - `IMAGE_REPO_NAME`: ECR仓库名称
   - `IMAGE_TAG`: 镜像标签（如$CODEBUILD_RESOLVED_SOURCE_VERSION）
   - `CONTAINER_NAME`: 容器名称

## 🔄 CI/CD流水线

### GitHub Actions工作流

工作流在以下情况下触发：
- 推送到`main`或`develop`分支
- 创建针对`main`分支的Pull Request

流水线包含三个主要作业：

1. **测试** (`test`)
   - 运行Go单元测试
   - 生成代码覆盖率报告
   - 上传覆盖率到Codecov

2. **构建和部署** (`build-and-deploy`)
   - 构建Docker镜像
   - 推送到Amazon ECR
   - 更新ECS服务

3. **安全扫描** (`security-scan`)
   - 使用Trivy扫描漏洞
   - 上传结果到GitHub Security

### 配置GitHub Secrets

在GitHub仓库设置中添加以下secrets：

```
AWS_ACCESS_KEY_ID=your_access_key_id
AWS_SECRET_ACCESS_KEY=your_secret_access_key
```

## 🔧 配置说明

### 环境变量

- `PORT`: 应用监听端口（默认: 8080）
- `AWS_REGION`: AWS区域（默认: us-east-1）
- `ECR_REPOSITORY`: ECR仓库名称
- `ECS_CLUSTER`: ECS集群名称
- `ECS_SERVICE`: ECS服务名称

### AWS资源

项目使用以下AWS服务：
- **Amazon ECR**: 存储Docker镜像
- **Amazon ECS**: 运行容器化应用
- **AWS Fargate**: 无服务器容器运行环境
- **Amazon CloudWatch**: 日志和监控
- **AWS CodeBuild**: 构建服务（可选）
- **AWS CodePipeline**: CI/CD流水线（可选）

## 📊 API端点

- `GET /` - 应用主页
- `GET /health` - 健康检查端点
- `GET /api/message` - 示例消息API

示例响应：

```json
// GET /health
{
  "status": "healthy",
  "timestamp": "2026-01-31T10:00:00Z",
  "version": "1.0.0"
}

// GET /api/message
{
  "message": "Hello from AWS CI/CD Pipeline! 🚀",
  "timestamp": "2026-01-31T10:00:00Z"
}
```

## 🧪 测试

运行所有测试：
```bash
go test -v ./...
```

运行带覆盖率的测试：
```bash
go test -v -cover ./...
```

生成覆盖率报告：
```bash
go test -coverprofile=coverage.out ./...
go tool cover -html=coverage.out
```

## 📈 监控和日志

### CloudWatch日志

应用日志自动发送到CloudWatch：
```
日志组: /ecs/aws-cicd-app
```

### 健康检查

ECS任务定义包含健康检查配置：
- 间隔: 30秒
- 超时: 5秒
- 重试次数: 3次
- 启动期: 60秒

## 🔒 安全最佳实践

1. ✅ 使用IAM角色而非访问密钥
2. ✅ 启用ECR镜像扫描
3. ✅ 使用Trivy进行漏洞扫描
4. ✅ 在Secrets Manager中存储敏感信息
5. ✅ 最小权限原则（Least Privilege）
6. ✅ 启用CloudWatch Container Insights

## 🛠️ 故障排查

### 常见问题

**问题**: Docker构建失败
```bash
# 解决方案：清理Docker缓存
docker system prune -a
```

**问题**: ECS任务无法启动
```bash
# 检查CloudWatch日志
aws logs tail /ecs/aws-cicd-app --follow
```

**问题**: GitHub Actions部署失败
- 确认AWS credentials正确配置
- 检查ECR仓库是否存在
- 验证IAM权限

## 📚 学习资源

- [AWS ECS Documentation](https://docs.aws.amazon.com/ecs/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Docker Documentation](https://docs.docker.com/)
- [Golang Documentation](https://golang.org/doc/)

## 🤝 贡献

欢迎提交Issue和Pull Request！

## 📄 许可证

MIT License

## 👤 作者

[@yige666s](https://github.com/yige666s)

---

⭐ 如果这个项目对你有帮助，请给它一个星标！