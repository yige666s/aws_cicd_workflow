# 部署参考文档

## AWS 资源信息

### EKS 集群
- **集群名称**: `ferocious-rock-goose`
- **区域**: `us-east-1`
- **版本**: `1.34`
- **状态**: `ACTIVE`
- **节点数**: 2

### ECR 仓库
- **仓库名称**: `app`
- **仓库 URI**: `483739914637.dkr.ecr.us-east-1.amazonaws.com/app`
- **镜像扫描**: 已启用
- **加密**: AES256
- **生命周期策略**: 保留最新 10 个镜像

### IAM 角色
- **GitHub Actions 角色**: `arn:aws:iam::483739914637:role/github_workflow_role`
- **认证方式**: OIDC

## 常用命令

### 本地开发

```bash
# 运行应用
go run main.go

# 运行测试
go test -v ./...

# 构建 Docker 镜像
docker build -t app .

# 本地运行容器
docker run -p 8080:8080 app
```

### Kubernetes 操作

```bash
# 更新 kubeconfig
aws eks update-kubeconfig --region us-east-1 --name ferocious-rock-goose

# 查看集群节点
kubectl get nodes

# 查看所有资源
kubectl get all

# 查看 Deployment
kubectl get deployment app
kubectl describe deployment app

# 查看 Pods
kubectl get pods
kubectl describe pod <pod-name>

# 查看 Service
kubectl get service app
kubectl describe service app

# 查看日志
kubectl logs -f deployment/app
kubectl logs <pod-name>

# 手动部署（如果需要）
kubectl apply -f k8s/

# 删除部署
kubectl delete -f k8s/

# 扩容/缩容
kubectl scale deployment app --replicas=3

# 重启 Deployment
kubectl rollout restart deployment/app

# 查看滚动更新状态
kubectl rollout status deployment/app

# 查看滚动更新历史
kubectl rollout history deployment/app
```

### ECR 操作

```bash
# 登录 ECR
aws ecr get-login-password --region us-east-1 | \
  docker login --username AWS --password-stdin \
  483739914637.dkr.ecr.us-east-1.amazonaws.com

# 列出镜像
aws ecr list-images --repository-name app --region us-east-1

# 查看镜像详情
aws ecr describe-images --repository-name app --region us-east-1

# 手动推送镜像
docker tag app:latest 483739914637.dkr.ecr.us-east-1.amazonaws.com/app:latest
docker push 483739914637.dkr.ecr.us-east-1.amazonaws.com/app:latest

# 删除镜像
aws ecr batch-delete-image \
  --repository-name app \
  --region us-east-1 \
  --image-ids imageTag=<tag>
```

### GitHub Actions

```bash
# 触发部署（推送到 main 分支）
git add .
git commit -m "your message"
git push origin main

# 查看 Actions 状态
# 访问: https://github.com/yige666s/aws_cicd_workflow/actions
```

## 部署流程

### 自动部署（推荐）

1. 修改代码
2. 提交并推送到 `main` 分支
3. GitHub Actions 自动执行：
   - 构建 Docker 镜像
   - 推送到 ECR
   - 部署到 EKS
   - 等待滚动更新完成

### 手动部署

```bash
# 1. 构建并推送镜像
docker build -t 483739914637.dkr.ecr.us-east-1.amazonaws.com/app:manual .
docker push 483739914637.dkr.ecr.us-east-1.amazonaws.com/app:manual

# 2. 更新 k8s/deployment.yaml 中的镜像标签
sed -i '' 's|__IMAGE__|483739914637.dkr.ecr.us-east-1.amazonaws.com/app:manual|g' k8s/deployment.yaml

# 3. 应用配置
kubectl apply -f k8s/

# 4. 查看部署状态
kubectl rollout status deployment/app
```

## 故障排查

### Pod 无法启动

```bash
# 查看 Pod 状态
kubectl get pods

# 查看 Pod 详情
kubectl describe pod <pod-name>

# 查看日志
kubectl logs <pod-name>

# 查看事件
kubectl get events --sort-by='.lastTimestamp'
```

### 镜像拉取失败

```bash
# 检查 ECR 仓库
aws ecr describe-repositories --repository-names app --region us-east-1

# 检查镜像是否存在
aws ecr list-images --repository-name app --region us-east-1

# 检查 IAM 权限
aws eks describe-cluster --name ferocious-rock-goose --region us-east-1
```

### Service 无法访问

```bash
# 查看 Service
kubectl get service app

# 查看 Endpoints
kubectl get endpoints app

# 测试 Service（从集群内部）
kubectl run -it --rm debug --image=busybox --restart=Never -- wget -O- http://app:80
```

## 监控和日志

### 查看应用日志

```bash
# 实时查看日志
kubectl logs -f deployment/app

# 查看最近的日志
kubectl logs --tail=100 deployment/app

# 查看所有 Pod 的日志
kubectl logs -l app=app --all-containers=true
```

### 查看资源使用情况

```bash
# 查看节点资源
kubectl top nodes

# 查看 Pod 资源
kubectl top pods
```

## API 端点

应用提供以下端点：

- `GET /` - 应用主页
- `GET /health` - 健康检查
- `GET /api/message` - 示例消息 API

### 访问应用

```bash
# 通过 Service（集群内部）
kubectl run -it --rm debug --image=curlimages/curl --restart=Never -- \
  curl http://app:80/health

# 端口转发到本地
kubectl port-forward service/app 8080:80

# 然后在本地访问
curl http://localhost:8080/health
```

## 清理资源

```bash
# 删除 Kubernetes 资源
kubectl delete -f k8s/

# 删除 ECR 仓库（谨慎操作）
aws ecr delete-repository --repository-name app --region us-east-1 --force

# 删除 EKS 集群（谨慎操作）
# 需要通过 AWS Console 或 Terraform 删除
```

## 安全最佳实践

1. ✅ 使用 OIDC 而非长期访问密钥
2. ✅ 启用 ECR 镜像扫描
3. ✅ 使用最小权限原则
4. ✅ 定期更新依赖和基础镜像
5. ✅ 使用 Kubernetes RBAC 控制访问
6. ✅ 启用 Pod Security Standards

## 相关链接

- [GitHub Repository](https://github.com/yige666s/aws_cicd_workflow)
- [GitHub Actions](https://github.com/yige666s/aws_cicd_workflow/actions)
- [AWS EKS Console](https://console.aws.amazon.com/eks/home?region=us-east-1#/clusters/ferocious-rock-goose)
- [AWS ECR Console](https://console.aws.amazon.com/ecr/repositories/private/483739914637/app?region=us-east-1)
