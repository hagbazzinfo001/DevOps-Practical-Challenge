#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
cd "$SCRIPT_DIR/../k8s"

echo "1. Installing NGINX Ingress Controller..."
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.10.0/deploy/static/provider/aws/deploy.yaml

echo "2. Installing Cert-Manager..."
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.14.4/cert-manager.yaml

echo "Waiting 45 seconds for Cert-Manager Webhooks to register locally..."
sleep 45

echo "3. Applying Let's Encrypt ClusterIssuer..."
kubectl apply -f cluster-issuer.yaml

echo "4. Deploying Capstone Application into 'taskapp' namespace..."
kubectl apply -f core-secrets.yaml
kubectl apply -f postgres.yaml
kubectl apply -f backend.yaml
kubectl apply -f frontend.yaml
kubectl apply -f ingress.yaml

echo ""
echo "✅ All Kubernetes resources applied. Run 'kubectl get pods -n taskapp' to monitor startup!"
