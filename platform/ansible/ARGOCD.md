# ArgoCD Installation Guide

## Overview

ArgoCD has been added to the Ansible infrastructure setup and will be automatically installed when you run the playbook. This document explains how ArgoCD is configured and how to use it.

## What Gets Installed

The Ansible playbook now includes:

1. **ArgoCD Server** - GitOps continuous deployment tool
2. **ArgoCD CLI** - Command-line interface for ArgoCD management
3. **NodePort Service** - External access to ArgoCD web interface
4. **Firewall Rules** - Proper ports opened for ArgoCD access

## Installation Details

### ArgoCD Components

- **Namespace**: `argocd`
- **Web UI Port**: `30080` (NodePort)
- **gRPC Port**: `30443` (NodePort)
- **Admin User**: `admin`
- **Admin Password**: Auto-generated (displayed during installation)

### Firewall Configuration

The following ports are automatically opened:
- `30080/tcp` - ArgoCD Web UI
- `30443/tcp` - ArgoCD gRPC API

## Post-Installation Access

### Web Interface

Access ArgoCD web interface at:
```
http://YOUR_SERVER_IP:30080
```

### Login Credentials

- **Username**: `admin`
- **Password**: Displayed in the Ansible playbook output

If you need to retrieve the password later:
```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

### CLI Access

ArgoCD CLI is installed at `/usr/local/bin/argocd`. You can use it to:

```bash
# Login via CLI
argocd login YOUR_SERVER_IP:30443 --username admin --password YOUR_PASSWORD --insecure

# List applications
argocd app list

# Create application
argocd app create banking-api --repo https://github.com/your-org/banking-api-config.git --path environments/production --dest-server https://kubernetes.default.svc --dest-namespace banking-api
```

## GitOps Workflow Integration

With ArgoCD installed, you can now implement GitOps workflows:

### 1. Create GitOps Repository

Create a separate repository for GitOps configuration:
```
banking-api-config/
├── environments/
│   ├── dev/
│   ├── staging/
│   └── production/
└── base/
```

### 2. Create ArgoCD Applications

Example application manifest for production:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: banking-api-prod
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/sameedshoaibb/banking-api-config
    targetRevision: HEAD
    path: environments/production
  destination:
    server: https://kubernetes.default.svc
    namespace: banking-api
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
```

### 3. Update CI/CD Pipeline

Modify your Jenkins pipeline to update the GitOps repository instead of directly deploying to Kubernetes:

```groovy
stage('Update GitOps Config') {
    steps {
        script {
            // Clone GitOps repo
            git credentialsId: 'github-credentials', url: 'https://github.com/sameedshoaibb/banking-api-config.git'
            
            // Update image tag
            sh """
                yq eval '.image.tag = "${IMAGE_TAG}"' -i environments/dev/values.yaml
                git add environments/dev/values.yaml
                git commit -m "Update dev image to ${IMAGE_TAG}"
                git push origin main
            """
        }
    }
}
```

## Benefits

1. **Declarative Configuration** - All configurations stored in Git
2. **Automated Sync** - ArgoCD automatically applies changes from Git
3. **Drift Detection** - Detects and corrects configuration drift
4. **Rollback Capability** - Easy rollback using Git history
5. **Multi-Environment** - Manage multiple environments consistently

## Troubleshooting

### ArgoCD Not Accessible

Check if ArgoCD pods are running:
```bash
kubectl get pods -n argocd
```

Check ArgoCD service:
```bash
kubectl get svc -n argocd argocd-server
```

### Password Issues

Reset ArgoCD admin password:
```bash
# Generate new password
argocd account update-password --account admin --current-password CURRENT_PASS --new-password NEW_PASS

# Or reset via kubectl
kubectl -n argocd patch secret argocd-secret -p '{"data": {"admin.password": null, "admin.passwordMtime": null}}'
kubectl -n argocd scale deployment argocd-server --replicas=0
kubectl -n argocd scale deployment argocd-server --replicas=1
```

### Firewall Issues

Ensure ports are open:
```bash
sudo ufw status
sudo ufw allow 30080/tcp
sudo ufw allow 30443/tcp
```

## Security Considerations

1. **Change Default Password** - Change the auto-generated admin password after first login
2. **Enable RBAC** - Configure proper role-based access control
3. **Use HTTPS** - Configure TLS for production environments
4. **Network Policies** - Implement network policies for additional security

The ArgoCD installation provides a solid foundation for implementing GitOps workflows in your DevOps pipeline.