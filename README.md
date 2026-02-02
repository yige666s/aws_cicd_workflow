# AWS CI/CD Workflow - Golang 示例项目

这是一个用于学习和实践AWS CI/CD工作流的Golang示例项目。项目展示了如何使用GitHub Actions构建和部署容器化的Go应用到AWS EKS Auto Mode。

## 📋 项目概述

本项目包含：
- ✅ 简单的Golang Web应用（HTTP服务器）
- ✅ 完整的单元测试
- ✅ Docker容器化配置
- ✅ GitHub Actions CI/CD流水线
- ✅ AWS EKS Auto Mode 部署
- ✅ Kubernetes 配置文件
- ✅ Terraform基础设施即代码

## 🏗️ 项目结构

```
.
├── main.go                    # 主应用程序
├── main_test.go              # 单元测试
├── go.mod                    # Go模块文件
├── Dockerfile                # Docker镜像配置
├── .dockerignore            # Docker忽略文件
├── Makefile                 # 构建和部署命令
├── .github/
│   └── workflows/
│       └── deploy.yml       # GitHub Actions工作流
├── k8s/
│   ├── deployment.yaml      # Kubernetes Deployment配置
│   └── service.yaml         # Kubernetes Service配置
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
- 具有适当权限的IAM用户或角色
- Docker已安装
- kubectl已安装

### 方法1: 使用Terraform

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

### 方法2: 使用GitHub Actions（推荐）

1. **配置GitHub OIDC**
   - 在AWS中创建OIDC提供商
   - 创建IAM角色并配置信任关系
   - 更新 `.github/workflows/deploy.yml` 中的角色ARN

2. **推送代码到main分支**
```bash
git add .
git commit -m "Deploy to EKS"
git push origin main
```

GitHub Actions会自动：
- 构建Docker镜像
- 推送到ECR
- 部署到EKS集群

## 🔄 CI/CD流水线

### GitHub Actions工作流

工作流在以下情况下触发：
- 推送到`main`分支

流水线执行以下步骤：

1. **配置AWS凭证**
   - 使用OIDC方式获取临时凭证
   - 无需在GitHub中存储长期密钥

2. **构建和推送镜像**
   - 登录到Amazon ECR
   - 构建Docker镜像
   - 推送镜像到ECR

3. **部署到EKS**
   - 更新kubeconfig
   - 替换Deployment中的镜像标签
   - 应用Kubernetes配置
   - 等待滚动更新完成

### 配置要求

确保在AWS中正确配置了：
- OIDC提供商（GitHub）
- IAM角色及信任策略
- ECR仓库
- EKS集群

## 🔧 配置说明

### 环境变量

- `PORT`: 应用监听端口（默认: 8080）
- `AWS_REGION`: AWS区域（默认: us-east-1）
- `ECR_REPO`: ECR仓库名称
- `EKS_CLUSTER_NAME`: EKS集群名称

### AWS资源

项目使用以下AWS服务：
- **Amazon ECR**: 存储Docker镜像
- **Amazon EKS Auto Mode**: 运行Kubernetes工作负载
- **AWS IAM**: 身份和访问管理（OIDC）
- **Amazon CloudWatch**: 日志和监控

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

应用日志可以通过kubectl查看：
```bash
kubectl logs -f deployment/app
```

### 健康检查

可以通过以下方式检查应用健康状态：
```bash
kubectl get pods
kubectl describe deployment app
```

## 🔒 安全最佳实践

1. ✅ 使用OIDC而非长期访问密钥
2. ✅ 启用ECR镜像扫描
3. ✅ 使用Kubernetes RBAC控制访问
4. ✅ 在Secrets Manager中存储敏感信息
5. ✅ 最小权限原则（Least Privilege）
6. ✅ 定期更新依赖和基础镜像

## 🛠️ 故障排查

### 常见问题

**问题**: Docker构建失败
```bash
# 解决方案：清理Docker缓存
docker system prune -a
```

**问题**: Pod无法启动
```bash
# 检查Pod状态
kubectl get pods
kubectl describe pod <pod-name>
kubectl logs <pod-name>
```

**问题**: GitHub Actions部署失败
- 确认AWS OIDC配置正确
- 检查ECR仓库是否存在
- 验证IAM角色权限
- 确认EKS集群可访问

## 📚 学习资源

- [AWS EKS Documentation](https://docs.aws.amazon.com/eks/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
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