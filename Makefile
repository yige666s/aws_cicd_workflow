# Makefile for AWS CI/CD Workflow Project

.PHONY: help build run test clean docker-build docker-run deploy-local

help: ## 显示帮助信息
	@echo "可用的命令:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

build: ## 编译Go应用
	@echo "Building application..."
	go build -o bin/app main.go

run: ## 运行应用
	@echo "Running application..."
	go run main.go

test: ## 运行测试
	@echo "Running tests..."
	go test -v -cover ./...

test-coverage: ## 运行测试并生成覆盖率报告
	@echo "Running tests with coverage..."
	go test -v -coverprofile=coverage.out ./...
	go tool cover -html=coverage.out -o coverage.html
	@echo "Coverage report generated: coverage.html"

clean: ## 清理构建文件
	@echo "Cleaning..."
	rm -rf bin/
	rm -f coverage.out coverage.html
	go clean

docker-build: ## 构建Docker镜像
	@echo "Building Docker image..."
	docker build -t aws-cicd-app:latest .

docker-run: ## 运行Docker容器
	@echo "Running Docker container..."
	docker run -p 8080:8080 --rm aws-cicd-app:latest

docker-stop: ## 停止所有运行中的容器
	@echo "Stopping all containers..."
	docker stop $$(docker ps -q) || true

deploy-local: build ## 本地部署
	@echo "Deploying locally..."
	./bin/app

lint: ## 运行代码检查
	@echo "Running linters..."
	go fmt ./...
	go vet ./...

deps: ## 下载依赖
	@echo "Downloading dependencies..."
	go mod download
	go mod tidy

aws-setup: ## 设置AWS基础设施
	@echo "Setting up AWS infrastructure..."
	chmod +x aws/setup-infrastructure.sh
	./aws/setup-infrastructure.sh

aws-ecs-task: ## 创建ECS任务定义
	@echo "Setting up ECS task definition..."
	chmod +x aws/setup-ecs-task.sh
	./aws/setup-ecs-task.sh

terraform-init: ## 初始化Terraform
	@echo "Initializing Terraform..."
	cd terraform && terraform init

terraform-plan: ## 查看Terraform执行计划
	@echo "Planning Terraform changes..."
	cd terraform && terraform plan

terraform-apply: ## 应用Terraform配置
	@echo "Applying Terraform configuration..."
	cd terraform && terraform apply

terraform-destroy: ## 销毁Terraform资源
	@echo "Destroying Terraform resources..."
	cd terraform && terraform destroy
