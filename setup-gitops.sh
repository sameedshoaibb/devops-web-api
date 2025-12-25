#!/bin/bash
# ArgoCD GitOps Setup Script
# This script sets up ArgoCD applications to watch for changes in your Helm values files

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
ARGOCD_SERVER="localhost:30080"
ARGOCD_ADMIN_PASSWORD=""

echo -e "${YELLOW}Setting up GitOps with ArgoCD...${NC}"

# Function to check if ArgoCD is accessible
check_argocd() {
    echo "Checking ArgoCD availability..."
    if ! curl -s "http://$ARGOCD_SERVER/api/version" > /dev/null; then
        echo -e "${RED}Error: ArgoCD is not accessible at http://$ARGOCD_SERVER${NC}"
        echo "Please ensure ArgoCD is running and accessible."
        exit 1
    fi
    echo -e "${GREEN}✓ ArgoCD is accessible${NC}"
}

# Function to get ArgoCD password
get_argocd_password() {
    if [ -z "$ARGOCD_ADMIN_PASSWORD" ]; then
        echo -e "${YELLOW}Getting ArgoCD admin password...${NC}"
        ARGOCD_ADMIN_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d 2>/dev/null || echo "")
        
        if [ -z "$ARGOCD_ADMIN_PASSWORD" ]; then
            echo -e "${RED}Could not retrieve ArgoCD password automatically.${NC}"
            echo -e "${YELLOW}Please enter ArgoCD admin password:${NC}"
            read -s ARGOCD_ADMIN_PASSWORD
        else
            echo -e "${GREEN}✓ ArgoCD password retrieved${NC}"
        fi
    fi
}

# Function to login to ArgoCD
login_argocd() {
    echo "Logging into ArgoCD..."
    if argocd login "$ARGOCD_SERVER" --username admin --password "$ARGOCD_ADMIN_PASSWORD" --insecure; then
        echo -e "${GREEN}✓ Successfully logged into ArgoCD${NC}"
    else
        echo -e "${RED}Failed to login to ArgoCD${NC}"
        exit 1
    fi
}

# Function to apply ArgoCD applications
apply_applications() {
    echo "Applying ArgoCD applications..."
    
    if kubectl apply -f argocd-applications.yaml; then
        echo -e "${GREEN}✓ ArgoCD applications created successfully${NC}"
    else
        echo -e "${RED}Failed to create ArgoCD applications${NC}"
        exit 1
    fi
}

# Function to check application status
check_application_status() {
    echo "Checking application status..."
    
    apps=("banking-api-production" "banking-api-staging" "banking-api-dev")
    
    for app in "${apps[@]}"; do
        echo -e "${YELLOW}Checking $app...${NC}"
        kubectl get application "$app" -n argocd -o wide 2>/dev/null || echo -e "${YELLOW}Application $app not found yet${NC}"
    done
}

# Function to sync applications
sync_applications() {
    echo "Syncing applications..."
    
    apps=("banking-api-production" "banking-api-staging" "banking-api-dev")
    
    for app in "${apps[@]}"; do
        echo -e "${YELLOW}Syncing $app...${NC}"
        argocd app sync "$app" --timeout 300 || echo -e "${YELLOW}Sync failed for $app, will retry automatically${NC}"
    done
}

# Function to show final information
show_final_info() {
    echo -e "${GREEN}"
    echo "========================================="
    echo "GitOps Setup Complete!"
    echo "========================================="
    echo -e "${NC}"
    
    echo -e "${YELLOW}ArgoCD Applications Created:${NC}"
    echo "• banking-api-production (uses values.prod.yaml)"
    echo "• banking-api-staging (uses values.staging.yaml)"  
    echo "• banking-api-dev (uses values.dev.yaml)"
    echo ""
    
    echo -e "${YELLOW}How it works:${NC}"
    echo "1. ArgoCD monitors your Git repository for changes"
    echo "2. When you update values.prod.yaml and push to Git"
    echo "3. ArgoCD automatically detects the change"
    echo "4. ArgoCD syncs the new configuration to Kubernetes"
    echo "5. Your application is updated automatically"
    echo ""
    
    echo -e "${YELLOW}Access Information:${NC}"
    echo "• ArgoCD Web UI: http://$ARGOCD_SERVER"
    echo "• Username: admin"
    echo "• Password: $ARGOCD_ADMIN_PASSWORD"
    echo ""
    
    echo -e "${YELLOW}To test the GitOps workflow:${NC}"
    echo "1. Edit banking-api/helm/values.prod.yaml"
    echo "2. Change the app.imageTag to a new version"
    echo "3. Commit and push the changes to Git"
    echo "4. Watch ArgoCD automatically deploy the changes"
    echo ""
    
    echo -e "${YELLOW}CLI Commands:${NC}"
    echo "• argocd app list"
    echo "• argocd app get banking-api-production"
    echo "• argocd app sync banking-api-production"
    echo "• argocd app history banking-api-production"
    echo ""
}

# Main execution
main() {
    echo -e "${YELLOW}Starting ArgoCD GitOps setup...${NC}"
    
    check_argocd
    get_argocd_password
    login_argocd
    apply_applications
    
    # Wait a bit for applications to be created
    echo "Waiting for applications to be initialized..."
    sleep 10
    
    check_application_status
    sync_applications
    show_final_info
    
    echo -e "${GREEN}✓ GitOps setup complete!${NC}"
}

# Run main function
main "$@"