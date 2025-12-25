#!/bin/bash
# Script to deploy ArgoCD applications with specific file monitoring

echo "🚀 Deploying ArgoCD Applications for GitOps..."

# Set ArgoCD server details
ARGOCD_SERVER="localhost:30080"
ARGOCD_USER="admin"

# Get ArgoCD password
echo "📋 Getting ArgoCD admin password..."
ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

if [ -z "$ARGOCD_PASSWORD" ]; then
    echo "❌ Could not retrieve ArgoCD password. Make sure ArgoCD is running."
    exit 1
fi

echo "✅ ArgoCD password retrieved successfully"
echo "🌐 ArgoCD UI: http://$ARGOCD_SERVER"
echo "👤 Username: $ARGOCD_USER"
echo "🔑 Password: $ARGOCD_PASSWORD"

# Apply the main applications
echo "📦 Applying main ArgoCD applications..."
kubectl apply -f argocd-applications.yaml

# Apply the values-only watcher
echo "👁️  Applying values-only watcher application..."
kubectl apply -f argocd-values-watcher.yaml

# Wait for applications to be created
echo "⏳ Waiting for applications to be created..."
sleep 10

# Check application status
echo "📊 Checking application status..."
kubectl get applications -n argocd

echo ""
echo "🎯 Available Options for Monitoring Files:"
echo "=========================================="
echo ""
echo "1. 📁 FULL FOLDER MONITORING (Default):"
echo "   - Application: banking-api-production"
echo "   - Monitors: Entire banking-api/helm folder"
echo "   - Triggers on: Any file change in the folder"
echo ""
echo "2. 📄 SPECIFIC FILE MONITORING (New):"
echo "   - Application: banking-api-prod-config-watcher"
echo "   - Monitors: Only values*.yaml files"
echo "   - Triggers on: Changes to values.yaml or values.prod.yaml only"
echo ""
echo "🔧 TO CONFIGURE SPECIFIC FILE MONITORING:"
echo "=========================================="
echo ""
echo "Option A - Via ArgoCD UI:"
echo "1. Go to http://$ARGOCD_SERVER"
echo "2. Login with admin/$ARGOCD_PASSWORD"
echo "3. Click on 'banking-api-prod-config-watcher' application"
echo "4. Go to 'App Details' > 'Parameters'"
echo "5. Add include/exclude patterns under Source"
echo ""
echo "Option B - Via CLI:"
echo "argocd app set banking-api-prod-config-watcher --source-path 'banking-api/helm' --directory-include 'values.prod.yaml'"
echo ""
echo "Option C - Via Webhook (Advanced):"
echo "Set up GitHub webhook to trigger sync only when values.prod.yaml changes"
echo ""
echo "✅ Setup Complete! Your applications will now monitor for changes."
echo ""
echo "🧪 TO TEST THE MONITORING:"
echo "=========================="
echo "1. Edit banking-api/helm/values.prod.yaml in your repo"
echo "2. Commit and push the changes"
echo "3. Watch ArgoCD automatically detect and sync the changes"
echo "4. Check the application status in ArgoCD UI"