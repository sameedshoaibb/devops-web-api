#!/bin/bash
# Script to configure ArgoCD for specific file monitoring

echo "🎯 Configuring ArgoCD for values.prod.yaml monitoring"

# Check if ArgoCD CLI is available
if ! command -v argocd &> /dev/null; then
    echo "📦 Installing ArgoCD CLI..."
    curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
    chmod +x /usr/local/bin/argocd
fi

# Get ArgoCD credentials
ARGOCD_SERVER="localhost:30080"
ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

echo "🔑 Logging into ArgoCD..."
argocd login $ARGOCD_SERVER --username admin --password $ARGOCD_PASSWORD --insecure

echo "📋 Current ArgoCD Applications:"
kubectl get applications -n argocd

echo ""
echo "🎯 METHODS TO MONITOR ONLY values.prod.yaml:"
echo "============================================="
echo ""
echo "Method 1: Configure Refresh Interval (Recommended)"
echo "---------------------------------------------------"
echo "This sets up more frequent checking for your specific application:"

# Configure the application for more frequent refresh
argocd app set banking-api-production \
  --refresh-period 30s \
  --self-heal \
  --auto-prune

echo ""
echo "Method 2: Manual Sync with Path Filter"
echo "--------------------------------------"
echo "You can manually sync only when values.prod.yaml changes:"
echo ""
echo "# Command to sync only when values files change:"
echo "argocd app sync banking-api-production --prune --dry-run"
echo ""
echo "Method 3: GitHub Webhook Configuration"
echo "-------------------------------------"
echo "Set up a GitHub webhook that triggers ArgoCD refresh only for specific file changes:"
echo ""
echo "Webhook URL: http://your-argocd-server:30080/api/webhook"
echo "Content-Type: application/json"
echo "Events: push"
echo ""
cat << 'EOF'
# Example webhook payload filter (GitHub Actions):
name: ArgoCD Sync on Values Change
on:
  push:
    paths:
      - 'banking-api/helm/values.prod.yaml'
      - 'banking-api/helm/values.yaml'

jobs:
  sync:
    runs-on: ubuntu-latest
    steps:
      - name: Trigger ArgoCD Sync
        run: |
          curl -X POST http://your-argocd-server:30080/api/webhook \
            -H "Content-Type: application/json" \
            -d '{
              "repository": {
                "full_name": "sameedshoaibb/devops-web-api"
              },
              "commits": [{
                "modified": ["banking-api/helm/values.prod.yaml"]
              }]
            }'
EOF

echo ""
echo "Method 4: ArgoCD Application of Applications (App of Apps)"
echo "---------------------------------------------------------"
echo "Create a separate app that only manages values files:"

# Apply the specific file monitoring configuration
kubectl apply -f argocd-specific-file-monitoring.yaml

echo ""
echo "✅ Configuration Applied!"
echo ""
echo "🔍 TO VERIFY SPECIFIC FILE MONITORING:"
echo "======================================"
echo ""
echo "1. Check your applications:"
echo "   kubectl get applications -n argocd"
echo ""
echo "2. Watch application sync status:"
echo "   watch 'kubectl get applications -n argocd'"
echo ""
echo "3. Test by editing values.prod.yaml:"
echo "   - Edit banking-api/helm/values.prod.yaml"
echo "   - Commit and push"
echo "   - Watch ArgoCD detect the change"
echo ""
echo "4. Check application details in UI:"
echo "   http://$ARGOCD_SERVER"
echo "   Username: admin"
echo "   Password: $ARGOCD_PASSWORD"
echo ""
echo "🎉 Now your ArgoCD will be more responsive to values.prod.yaml changes!"