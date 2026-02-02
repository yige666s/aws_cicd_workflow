# Kubernetes 部署故障排查日志 (EKS 实战)

本文档记录了在 AWS EKS 集群上部署开源项目（2048 游戏和 Google Online Boutique）时遇到的实际问题及其解决方案。这些经验对于后续的 EKS 运维非常有参考价值。

## 1. 镜像版本过旧导致拉取失败

### 现象
部署 `alexwhen/docker-2048` 后，Pod 状态停留在 `ImagePullBackOff` 或 `ErrImagePull`。
`kubectl describe pod` 显示错误：
```
rpc error: code = InvalidArgument desc = failed to pull and unpack image "...": schema 1 image manifests are no longer supported
```

### 原因
Kubernetes 现在的容器运行时（containerd）已经不再支持旧版的 Docker Schema 1 镜像 manifest 格式。许多几年前的老镜像（如 `alexwhen/docker-2048`）都是这种格式。

### 解决方案
更换为支持 Schema 2 的新镜像。
- **原镜像**: `alexwhen/docker-2048`
- **替换为**: `public.ecr.aws/l6m2t8p7/docker-2048:latest` (AWS 公共 ECR 中的镜像)

---

## 2. Pod 调度失败 (Taints & Tolerations)

### 现象
Pod 一直处于 `Pending` 状态。
`kubectl describe pod` 显示事件：
```
0/3 nodes are available: 3 node(s) had untolerated taint(s).
```

### 原因
EKS 集群的节点可能带有污点（Taints），限制了普通 Pod 的调度。例如：
- `CriticalAddonsOnly=true:NoSchedule`: 预留给系统关键组件节点的污点。
- `karpenter.sh/disrupted:NoSchedule`: 节点正在被 Karpenter 回收或调整时打的污点。

普通 Pod 默认没有配置容忍（Toleration）这些污点，因此无法调度。

### 解决方案
在 Deployment 的 `spec.template.spec` 中添加 `tolerations` 配置，允许 Pod 调度到这些节点上（仅限测试环境）：

```yaml
      tolerations:
      - key: "CriticalAddonsOnly"
        operator: "Exists"
        effect: "NoSchedule"
```
*注：对于 Online Boutique，我们使用了脚本批量修改了所有 11 个 Deployment。*

---

## 3. LoadBalancer 创建失败 (Subnet Tags)

### 现象
Service 状态显示 `LoadBalancer`，但 `EXTERNAL-IP` 一直是 `<pending>`，没有分配 DNS。
`kubectl describe service` 显示事件：
```
Warning  FailedBuildModel ... Failed build model due to unable to resolve at least one subnet (0 match VPC and tags: [kubernetes.io/role/elb])
```

### 原因
AWS Load Balancer Controller（或内置 Cloud controller）需要通过特定的标签来识别哪些 VPC 子网可以用于放置公网 Load Balancer。如果子网缺少这些标签，控制器就不知道在哪里创建 LB。

### 解决方案
使用 AWS CLI 为集群所在的 VPC 子网手动添加必要的标签。

**查找 VPC 和子网:**
```bash
aws eks describe-cluster --name <cluster_name> --query 'cluster.resourcesVpcConfig.vpcId'
aws ec2 describe-subnets --filters "Name=vpc-id,Values=<vpc_id>"
```

**添加标签:**
所有公网子网都需要添加标签 `kubernetes.io/role/elb = 1`。

```bash
aws ec2 create-tags \
  --resources <subnet-id-1> <subnet-id-2> ... \
  --tags Key=kubernetes.io/role/elb,Value=1 \
  --region us-east-1
```
添加标签后，Service 控制器会自动检测到并成功创建 LoadBalancer (NLB/CLB)。

---

## 总结命令速查

### 强制删除 Terminating/Pending 的 Pod
```bash
kubectl delete pod -l app=<app_name> --field-selector=status.phase!=Running
```

### 查看节点污点 (Taints)
```bash
kubectl get nodes -o custom-columns=NAME:.metadata.name,TAINTS:.spec.taints
```

### 查看 Service 事件 (排查 LB 问题)
```bash
kubectl describe service <service_name>
```
