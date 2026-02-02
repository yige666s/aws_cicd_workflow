# Kubernetes 部署示例

这里包含了一些适合部署到 EKS 集群的经典开源项目示例。

## 1. 🎮 2048 游戏 (简单)

极简的静态网页游戏，适合快速验证集群扩缩容和负载均衡。

**部署:**
```bash
kubectl apply -f 2048.yaml
```

**访问:**
等待几分钟后获取 LoadBalancer URL：
```bash
kubectl get service game-2048 -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
```

**清理:**
```bash
kubectl delete -f 2048.yaml
```

---

## 2. 🛍️ Google Online Boutique (高级)

Google 官方的云原生微服务演示应用，包含 10 个微服务（Go, C#, Node.js, Python, Java 等），展示了完整的电商系统。

**部署:**
```bash
kubectl apply -f online-boutique.yaml
```

**访问:**
等待 Pods 全部启动（可能需要几分钟拉取镜像）：
```bash
kubectl get pods
```

获取前端访问地址：
```bash
kubectl get service frontend-external -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
```

**清理:**
```bash
kubectl delete -f online-boutique.yaml
```

> **注意**: Online Boutique 会创建约 12 个 Pod 和多个 Service，请确保你的集群有足够的资源（目前的 2 节点 t3.medium 应该足够）。
