package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"time"
)

// HealthResponse 健康检查响应结构
type HealthResponse struct {
	Status    string    `json:"status"`
	Timestamp time.Time `json:"timestamp"`
	Version   string    `json:"version"`
}

// MessageResponse 消息响应结构
type MessageResponse struct {
	Message   string    `json:"message"`
	Timestamp time.Time `json:"timestamp"`
}

func main() {
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	http.HandleFunc("/", homeHandler)
	http.HandleFunc("/health", healthHandler)
	http.HandleFunc("/api/message", messageHandler)

	log.Printf("Server starting on port %s...\n", port)
	if err := http.ListenAndServe(":"+port, nil); err != nil {
		log.Fatal(err)
	}
}

// homeHandler 首页处理器
func homeHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "text/html; charset=utf-8")
	html := `
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AWS CI/CD Demo</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 800px;
            margin: 50px auto;
            padding: 20px;
            background-color: #f5f5f5;
        }
        .container {
            background-color: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        h1 { color: #232f3e; }
        .btn {
            background-color: #ff9900;
            color: white;
            padding: 10px 20px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            margin: 10px 5px;
        }
        .btn:hover { background-color: #ec7211; }
        #result {
            margin-top: 20px;
            padding: 15px;
            background-color: #f0f0f0;
            border-radius: 5px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 AWS CI/CD 工作流示例</h1>
        <p>这是一个用Golang构建的示例应用，展示AWS CI/CD工作流。</p>
        
        <h2>功能演示</h2>
        <button class="btn" onclick="checkHealth()">健康检查</button>
        <button class="btn" onclick="getMessage()">获取消息</button>
        
        <div id="result"></div>
        
        <h2>API端点</h2>
        <ul>
            <li><code>GET /</code> - 首页</li>
            <li><code>GET /health</code> - 健康检查</li>
            <li><code>GET /api/message</code> - 获取消息</li>
        </ul>
    </div>
    
    <script>
        async function checkHealth() {
            try {
                const response = await fetch('/health');
                const data = await response.json();
                document.getElementById('result').innerHTML = 
                    '<strong>健康检查结果:</strong><br>' + 
                    JSON.stringify(data, null, 2);
            } catch (error) {
                document.getElementById('result').innerHTML = 
                    '<strong>错误:</strong> ' + error.message;
            }
        }
        
        async function getMessage() {
            try {
                const response = await fetch('/api/message');
                const data = await response.json();
                document.getElementById('result').innerHTML = 
                    '<strong>消息响应:</strong><br>' + 
                    JSON.stringify(data, null, 2);
            } catch (error) {
                document.getElementById('result').innerHTML = 
                    '<strong>错误:</strong> ' + error.message;
            }
        }
    </script>
</body>
</html>
`
	fmt.Fprint(w, html)
}

// healthHandler 健康检查处理器
func healthHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	response := HealthResponse{
		Status:    "healthy",
		Timestamp: time.Now(),
		Version:   "1.0.0",
	}
	json.NewEncoder(w).Encode(response)
}

// messageHandler 消息处理器
func messageHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	response := MessageResponse{
		Message:   "Hello from AWS CI/CD Pipeline! 🚀",
		Timestamp: time.Now(),
	}
	json.NewEncoder(w).Encode(response)
}
