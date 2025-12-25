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
├── platform/                          Platform - Infrastructure setup
│   ├── ansible/                       Ansible playbooks for automated provisioning
│   │   ├── ansible.cfg                Ansible configuration
│   │   ├── inventory.ini              Server inventory and details
│   │   ├── setup.yml                  Main setup playbook
│   │   ├── requirements.yml           Required Ansible roles
│   │   ├── group_vars/                Group variables configuration
│   │   ├── scripts/                   Installation scripts
│   │   ├── README.md                  Ansible documentation
│   │   └── ARGOCD.md                  ArgoCD setup guide
│   └── terraform/                     Infrastructure as Code for cloud (future)
│
└── care-banking-api/                  Application - Banking API code and deployment
    ├── src/                           Source code
    │   ├── index.ts                   Entry point
    │   ├── app.ts                     Express server setup
    │   ├── config.ts                  Configuration
    │   ├── state.ts                   Global state
    │   ├── adminRoutes.ts             Admin endpoints
    │   └── userRoutes.ts              User endpoints
    │
    ├── helm/                          Kubernetes deployment configuration
    │   ├── Chart.yaml                 Helm chart metadata
    │   ├── values.yaml                Default values
    │   ├── values.dev.yaml            Development environment values
    │   ├── values.staging.yaml        Staging environment values
    │   ├── values.prod.yaml           Production environment values
    │   └── templates/                 Kubernetes resource templates
    │       ├── rbac/                  Role-based access control templates
    │       ├── storage/               Persistent storage templates
    │       ├── policies/              Network and resource policy templates
    │       ├── advanced/              Auto-scaling and scheduling templates
    │       └── nginx/                 Nginx reverse proxy configuration
    │
    ├── Dockerfile                     Container image definition
    ├── Jenkinsfile                    CI/CD pipeline definition
    ├── package.json                   Node.js dependencies
    ├── start.sh                       Application startup script
    ├── config.json                    Application configuration
    ├── tsconfig.json                  TypeScript configuration
    └── scripts/                       Deployment utilities
        └── deploy/
            └── deploy.sh              Deployment script
```
    ├── start.sh
    ├── config.json
    ├── package.json
    ├── pnpm-lock.yaml
    ├── tsconfig.json
    ├── start.sh
    ├── README.md
    ├── .dockerignore
    ├── .gitignore
    ├── .prettierrc.yaml
    └── .prettierignore
```
