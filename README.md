# Care Banking API - OnCare DevOps Platform

## Purpose

This is a complete DevOps solution that automates building, testing, and deploying a Banking API application to a single-node Kubernetes cluster. It implements GitOps principles for automatic, secure, and reliable deployments using a minimal infrastructure setup. The platform supports multiple environments (development, staging, and production), with production environment currently set up and operational.

## What's Inside

### Platform Folder
Sets up and manages the entire infrastructure needed to run applications on Kubernetes.

What it contains:
- Ansible - Automated server setup scripts that install Docker, Kubernetes, Jenkins, and ArgoCD. Configures infrastructure and security. Sets up all required tools and services in one go.
  
- Terraform - Infrastructure as Code for cloud resources. Currently empty, but ready for future cloud infrastructure definitions. Provisions cloud resources like VMs, networks, and storage.

What it does: Everything needed to prepare your infrastructure. Run this once to set up your platform and you're ready to deploy applications.

### Care-Banking-Api Folder
The actual Banking API application that gets built and deployed.

What it contains:
- Source code - Node.js/TypeScript banking API with 6 endpoints for account management, user and admin routes.
  
- Helm charts - Kubernetes deployment configuration with environment-specific values for dev, staging, and production. The platform architecture supports all three environments, with production currently active. Development and staging environments are configured and ready for future setup. Contains Kubernetes templates for pods, services, storage, security, and more.
  
- Dockerfile - Container image definition with multi-stage build for optimized images, security hardening with non-root user, and built-in health checks.
  
- Jenkinsfile - CI/CD pipeline definition that automatically builds, tests, and deploys on every code change. Runs security scans, pushes to Docker Hub, and updates Kubernetes configuration.

What it does: Everything related to the application itself including code, builds, tests, and deployment configuration.

## How It Works (Simple Version)

1. Developer pushes code to GitHub
2. Jenkins automatically builds Docker image, runs security tests, pushes to Docker Hub, and updates deployment configuration
3. ArgoCD automatically detects configuration changes in GitHub and deploys new version to Kubernetes
4. App is live in about 5 minutes with zero manual work needed

## Key Technologies

1. Ansible - Used to automate infrastructure setup and install all required tools on a single Kubernetes node.

2. Terraform - Infrastructure as Code for cloud resources. Currently empty, but ready for future cloud infrastructure definitions.

3. Docker - Creates container images for the application with multi-stage builds and security hardening.

4. Helm - Provides Kubernetes deployment templates optimized for single-node setup with environment-specific configurations.

5. Jenkins - Handles CI/CD automation to build, test, and deploy code on every change with security scans.

6. ArgoCD - Manages continuous deployment using GitOps principles to automatically sync Git state with Kubernetes.

7. Kubernetes - Runs as a single-node cluster, suitable for development and testing environments.

## Getting Started

Setup Infrastructure (one-time only):
Navigate to the platform/ansible folder, edit the inventory.ini file with your server details, and run the setup playbook. This installs everything you need.

Deploy Application (automatic after initial setup):
Navigate to care-banking-api folder, make your changes, push to GitHub. Jenkins and ArgoCD handle all the building, testing, and deployment automatically.

## Project Structure

```
oncare-devops-task/
├── README.md
├── banking.md
│
├── platform/
│   ├── ansible/
│   │   ├── ansible.cfg
│   │   ├── inventory.ini
│   │   ├── setup.yml
│   │   ├── requirements.yml
│   │   ├── group_vars/
│   │   │   └── all.yml
│   │   ├── scripts/
│   │   ├── README.md
│   │   └── ARGOCD.md
│   └── terraform/
│
└── care-banking-api/
    ├── src/
    │   ├── index.ts
    │   ├── app.ts
    │   ├── config.ts
    │   ├── state.ts
    │   ├── adminRoutes.ts
    │   └── userRoutes.ts
    │
    ├── helm/
    │   ├── Chart.yaml
    │   ├── README.md
    │   ├── values.yaml
    │   ├── values.dev.yaml
    │   ├── values.staging.yaml
    │   ├── values.prod.yaml
    │   └── templates/
    │       ├── _helpers.tpl
    │       ├── deployment.yaml
    │       ├── service.yaml
    │       ├── configmap.yaml
    │       ├── secret.yaml
    │       ├── ingress.yaml
    │       ├── data-file-configmap.yaml
    │       ├── rbac/
    │       │   ├── role.yaml
    │       │   ├── rolebinding.yaml
    │       │   └── serviceaccount.yaml
    │       ├── storage/
    │       │   ├── pv.yaml
    │       │   └── pvc.yaml
    │       ├── policies/
    │       │   ├── networkpolicy.yaml
    │       │   ├── poddisruptionbudget.yaml
    │       │   └── resourcequota.yaml
    │       ├── advanced/
    │       │   ├── cronjob.yaml
    │       │   ├── hpa.yaml
    │       │   ├── vpa.yaml
    │       │   └── priorityclass.yaml
    │       ├── nginx/
    │       │   └── configmap-nginx.yaml
    │       └── tests/
    │           └── test-connection.yaml
    │
    ├── Dockerfile
    ├── Jenkinsfile
    ├── deploy.sh
    ├── start.sh
    ├── package.json
    ├── pnpm-lock.yaml
    ├── tsconfig.json
    ├── config.json
    ├── README.md
    ├── .dockerignore
    ├── .gitignore
    ├── .prettierrc.yaml
    └── .prettierignore
```
