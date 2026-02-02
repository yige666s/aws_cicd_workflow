#!/bin/bash

# 获取 LoadBalancer URL
LB_URL=$(kubectl get service app -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

if [ -z "$LB_URL" ]; then
    echo "❌ LoadBalancer URL not found. Service might not be ready yet."
    echo "Run: kubectl get service app"
    exit 1
fi

echo "🌐 Application Access Information"
echo "=================================="
echo ""
echo "LoadBalancer URL: http://$LB_URL"
echo ""
echo "Available Endpoints:"
echo "  - Home:         http://$LB_URL/"
echo "  - Health Check: http://$LB_URL/health"
echo "  - Message API:  http://$LB_URL/api/message"
echo ""
echo "Testing connection..."
echo ""

# Test health endpoint
if curl -s -m 5 http://$LB_URL/health > /dev/null 2>&1; then
    echo "✅ Application is accessible!"
    echo ""
    echo "Health Check Response:"
    curl -s http://$LB_URL/health | jq . 2>/dev/null || curl -s http://$LB_URL/health
    echo ""
    echo ""
    echo "📝 Quick Commands:"
    echo "  # Test in browser:"
    echo "  open http://$LB_URL"
    echo ""
    echo "  # Test with curl:"
    echo "  curl http://$LB_URL/health"
    echo ""
    echo "  # Watch logs:"
    echo "  kubectl logs -f -l app=app"
else
    echo "⚠️  Application is not responding yet."
    echo "   LoadBalancer might still be provisioning..."
    echo ""
    echo "   Please wait a few minutes and try again."
    echo "   You can check the status with:"
    echo "   kubectl get service app -w"
fi
