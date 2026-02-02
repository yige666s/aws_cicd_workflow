# 应用访问指南

## 🌐 公网访问（推荐）

应用已通过 AWS Network Load Balancer 暴露到公网。

### LoadBalancer URL

```
http://a7188c9faf2f749b681363ed2091e054-8e2b50963f5ac255.elb.us-east-1.amazonaws.com
```

### 可用端点

1. **主页**
   ```bash
   curl http://a7188c9faf2f749b681363ed2091e054-8e2b50963f5ac255.elb.us-east-1.amazonaws.com/
   ```

2. **健康检查**
   ```bash
   curl http://a7188c9faf2f749b681363ed2091e054-8e2b50963f5ac255.elb.us-east-1.amazonaws.com/health
   ```
   
   响应示例：
   ```json
   {
     "status": "healthy",
     "timestamp": "2026-02-02T06:57:40Z",
     "version": "1.0.0"
   }
   ```

3. **消息 API**
   ```bash
   curl http://a7188c9faf2f749b681363ed2091e054-8e2b50963f5ac255.elb.us-east-1.amazonaws.com/api/message
   ```

### 在浏览器中访问

直接在浏览器中打开：
```
http://a7188c9faf2f749b681363ed2091e054-8e2b50963f5ac255.elb.us-east-1.amazonaws.com
```

## 🔧 本地访问（开发/调试）

### 方法 1: 端口转发

```bash
# 转发到本地端口 8080
kubectl port-forward service/app 8080:80

# 然后访问
curl http://localhost:8080/health
```

### 方法 2: 直接访问 Pod

```bash
# 获取 Pod 名称
POD_NAME=$(kubectl get pods -l app=app -o jsonpath='{.items[0].metadata.name}')

# 端口转发到 Pod
kubectl port-forward $POD_NAME 8080:8080

# 访问
curl http://localhost:8080/health
```

## 📊 获取 LoadBalancer 信息

### 查看 Service 详情

```bash
kubectl get service app
```

输出示例：
```
NAME   TYPE           CLUSTER-IP     EXTERNAL-IP                          PORT(S)        AGE
app    LoadBalancer   10.100.245.8   a7188...elb.us-east-1.amazonaws.com  80:31497/TCP   10m
```

### 获取 LoadBalancer URL

```bash
# 获取 EXTERNAL-IP
kubectl get service app -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
```

### 等待 LoadBalancer 就绪

```bash
# 监控 Service 状态
kubectl get service app -w

# 等待 EXTERNAL-IP 出现（不是 <pending>）
```

## 🧪 测试应用

### 使用 curl

```bash
# 设置 LoadBalancer URL
LB_URL=$(kubectl get service app -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

# 测试健康检查
curl http://$LB_URL/health

# 测试主页
curl http://$LB_URL/

# 测试消息 API
curl http://$LB_URL/api/message
```

### 使用 httpie（如果已安装）

```bash
# 安装 httpie
brew install httpie  # macOS
# 或
apt install httpie   # Ubuntu

# 测试
http http://$LB_URL/health
```

### 压力测试

```bash
# 使用 ab (Apache Bench)
ab -n 1000 -c 10 http://$LB_URL/health

# 使用 hey
hey -n 1000 -c 10 http://$LB_URL/health
```

## 🔒 安全建议

### 当前配置

- ✅ LoadBalancer 类型：Network Load Balancer (NLB)
- ✅ 方案：internet-facing（公网可访问）
- ⚠️ 协议：HTTP（未加密）

### 生产环境建议

1. **添加 HTTPS 支持**
   - 使用 AWS Certificate Manager (ACM) 创建 SSL 证书
   - 在 Service 中配置证书

2. **限制访问**
   - 使用 Security Groups 限制入站流量
   - 配置 IP 白名单

3. **使用 Ingress Controller**
   - 安装 AWS Load Balancer Controller
   - 使用 Ingress 资源管理路由

## 📝 LoadBalancer 配置

当前 Service 配置（`k8s/service.yaml`）：

```yaml
apiVersion: v1
kind: Service
metadata:
  name: app
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-type: "nlb"
    service.beta.kubernetes.io/aws-load-balancer-scheme: "internet-facing"
spec:
  type: LoadBalancer
  selector:
    app: app
  ports:
    - port: 80
      targetPort: 8080
      protocol: TCP
```

### 可选配置

#### 内部 LoadBalancer（仅 VPC 内访问）

```yaml
annotations:
  service.beta.kubernetes.io/aws-load-balancer-type: "nlb"
  service.beta.kubernetes.io/aws-load-balancer-scheme: "internal"
```

#### 添加 SSL/TLS

```yaml
annotations:
  service.beta.kubernetes.io/aws-load-balancer-type: "nlb"
  service.beta.kubernetes.io/aws-load-balancer-ssl-cert: "arn:aws:acm:region:account-id:certificate/cert-id"
  service.beta.kubernetes.io/aws-load-balancer-ssl-ports: "443"
```

## 🛠️ 故障排查

### LoadBalancer 一直处于 Pending 状态

```bash
# 查看 Service 事件
kubectl describe service app

# 查看 AWS Load Balancer Controller 日志（如果安装了）
kubectl logs -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller
```

### 无法访问 LoadBalancer

1. **检查 Security Groups**
   ```bash
   # 在 AWS Console 中检查 NLB 的 Security Groups
   # 确保允许入站流量到端口 80
   ```

2. **检查 Pod 状态**
   ```bash
   kubectl get pods -l app=app
   kubectl logs -l app=app
   ```

3. **检查 Endpoints**
   ```bash
   kubectl get endpoints app
   ```

### 连接超时

```bash
# 检查 LoadBalancer 健康检查
aws elbv2 describe-target-health \
  --target-group-arn <target-group-arn>

# 测试从集群内部访问
kubectl run -it --rm debug --image=curlimages/curl --restart=Never -- \
  curl http://app:80/health
```

## 📊 监控

### 查看 LoadBalancer 指标

```bash
# 在 AWS Console 中查看
# CloudWatch > Metrics > ELB > Network Load Balancer
```

### 查看应用日志

```bash
# 实时日志
kubectl logs -f -l app=app

# 最近 100 行
kubectl logs --tail=100 -l app=app
```

## 🔄 更新应用

当你推送新代码到 `main` 分支时，GitHub Actions 会自动：
1. 构建新的 Docker 镜像
2. 推送到 ECR
3. 更新 Kubernetes Deployment
4. 执行滚动更新（零停机）

LoadBalancer 会自动将流量路由到新的 Pod。

## 💰 成本优化

### LoadBalancer 成本

- Network Load Balancer: ~$0.0225/小时 + 数据处理费用
- 每月约 $16-20（不含流量）

### 节省成本的选项

1. **使用 ClusterIP + Ingress**
   - 多个服务共享一个 LoadBalancer
   - 使用 AWS Load Balancer Controller

2. **使用 NodePort**
   - 直接访问节点 IP
   - 不推荐用于生产环境

3. **定期清理未使用的资源**
   ```bash
   # 删除 LoadBalancer（如果不需要）
   kubectl patch service app -p '{"spec":{"type":"ClusterIP"}}'
   ```

## 🔗 相关链接

- [AWS Network Load Balancer 文档](https://docs.aws.amazon.com/elasticloadbalancing/latest/network/)
- [Kubernetes Service 文档](https://kubernetes.io/docs/concepts/services-networking/service/)
- [AWS Load Balancer Controller](https://kubernetes-sigs.github.io/aws-load-balancer-controller/)
