# I have improved the script to include multiple environments

#!/bin/bash

# Get the environment (dev, staging, or prod)
ENVIRONMENT=$1

# Get the command (deploy, diff, lint, template, or uninstall) - default is deploy
COMMAND=${2:-deploy}

# Check if the environment is valid
if [ "$ENVIRONMENT" != "dev" ] && [ "$ENVIRONMENT" != "staging" ] && [ "$ENVIRONMENT" != "prod" ]; then
    echo "ERROR: Invalid environment: $ENVIRONMENT"
    echo "Valid environments are: dev, staging & prod"
    exit 1
fi

# Create the path to the values file
VALUES_FILE="./helm/values.$ENVIRONMENT.yaml"

# Check if the values file exists
if [ ! -f "$VALUES_FILE" ]; then
    echo "ERROR: Cannot find file: $VALUES_FILE"
    echo "Make sure you have a values file for $ENVIRONMENT environment"
    exit 1
fi

# Create namespace if it doesn't exist
create_namespace() {
    if ! kubectl get namespace banking-api &> /dev/null; then
        echo "Creating namespace: banking-api"
        kubectl create namespace banking-api
    fi
}

# Helm commands
if [ "$COMMAND" = "deploy" ]; then
    create_namespace
    echo "Deploying your application:"
    helm upgrade --install banking-api ./helm -f "$VALUES_FILE" -n banking-api
    echo ""
    echo "Deployment complete!"
    
elif [ "$COMMAND" = "diff" ]; then
    create_namespace
    echo "Checking the difference:"
    helm diff upgrade --install banking-api ./helm -f "$VALUES_FILE" -n banking-api
    echo ""
    echo "Difference complete!"

elif [ "$COMMAND" = "lint" ]; then
    echo "Linting the chart:"
    helm lint ./helm -f "$VALUES_FILE"
    echo ""
    echo "Lint complete!"

elif [ "$COMMAND" = "template" ]; then
    echo "Rendering templates:"
    helm template banking-api ./helm -f "$VALUES_FILE" -n banking-api
    echo ""
    echo "The template rendering complete!"

elif [ "$COMMAND" = "uninstall" ]; then
    echo "Uninstalling release:"
    helm uninstall banking-api -n banking-api
    echo ""
    echo "Uninstall complete!"
    
else
    echo "ERROR: Unknown command: $COMMAND"
    echo "Available commands: deploy, diff, lint, template, uninstall"
    exit 1
fi