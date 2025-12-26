# Care Banking API - DevOps Platform

## Purpose

This is a complete DevOps solution that automates building, testing, and deploying a Banking API application to a single-node Kubernetes cluster. It implements **GitOps principles** for automatic, secure, and reliable deployments using a minimal infrastructure setup. The platform supports multiple environments (development, staging, and production), with production environment currently set up and operational.

## What's Inside

### 01- Platform Folder
Sets up and manages the entire infrastructure needed to run applications on Kubernetes.

What it contains:
- **Terraform** - Infrastructure as Code for Azure. Creates a virtual machine with networking and security configured. Already deployed and ready to use.
  
- **Ansible** - Automated server configuration scripts that install Docker, Kubernetes, Jenkins, and ArgoCD on the Terraform-created VM. Configures infrastructure and security. Runs once on the VM to set up all required tools.

What it does: Terraform creates the cloud infrastructure, then Ansible configures it with all DevOps tools.

### 02- Care-Banking-Api Folder
The actual Banking API application that gets built and deployed.

What it contains:
- **Source code** - Node.js/TypeScript banking API with 6 endpoints for account management, user and admin routes.
  
- **Helm charts** - Kubernetes deployment configuration with environment-specific values for dev, staging, and production. The platform architecture supports all three environments, with production currently active. Development and staging environments are configured and ready for future setup. Contains Kubernetes templates for pods, services, storage, security, and more.
  
- **Dockerfile** - Container image definition with multi-stage build for optimized images, security hardening with non-root user, and built-in health checks.
  
- **Jenkinsfile** - CI/CD pipeline definition that automatically builds, tests, and deploys on every code change. Runs security scans, pushes to Docker Hub, and updates Kubernetes configuration.

What it does: Everything related to the application itself including code, builds, tests, and deployment configuration.

## Project Workflow

**Prerequisites (One-time Setup):**
- Set up Docker Hub account and create access token
- Create Jenkins pipeline and configure secrets
- Add Docker Hub credentials in Jenkins
- Set up GitHub webhook to trigger Jenkins pipeline
- Configure ArgoCD with Git repository access and target repositories for deployment
- Link ArgoCD to Kubernetes cluster

**Once setup is complete, the automated flow:**

1. **Developer pushes code to GitHub** - Push changes to the repository
2. **GitHub triggers Jenkins pipeline via webhook** - Automatic trigger on code push
3. **DevSecOps pipeline executes** - Builds Docker image, runs security tests, pushes to Docker Hub, updates deployment config
4. **ArgoCD detects configuration changes** - Automatically syncs to Kubernetes cluster
5. **App is live in ~5 minutes** - Zero manual work, fully automated

**For detailed pipeline setup and configuration**, see the README files in `platform/` and `care-banking-api/` folders.

## Key Technologies

1. **Terraform** - Creates cloud infrastructure on Azure (VM, network, security, monitoring).

2. **Ansible** - Configures the Terraform-created VM with Docker, Kubernetes, Jenkins, and ArgoCD.

3. **Docker** - Creates container images for the application with multi-stage builds and security hardening.

4. **Kubernetes** - Runs as a single-node cluster on the VM.

5. **Helm** - Kubernetes deployment templates optimized for single-node setup with environment-specific configurations.

6. **Jenkins** - Handles CI/CD automation to build, test, and deploy code on every change with security scans.

7. **ArgoCD** - Manages continuous deployment using GitOps principles to automatically sync Git state with Kubernetes.

## Getting Started

### Step 1: Terraform (Already Done)
The Azure infrastructure has been deployed with Terraform. You now have:
- Ubuntu VM running in Azure (UK West region)
- Virtual network with security rules configured
- Static public IP assigned to the VM
- Monitoring enabled for CPU alerts

**For detailed instructions:** See `platform/terraform/README.md`

### Step 2: Configure Ansible
Edit `platform/ansible/inventory.ini` with your Terraform VM details:
- VM public IP address (from terraform output)
- Admin username and password
- SSH key path (if using key-based authentication)

### Step 3: Run Ansible Playbook
From the `platform/ansible` folder, run:
```bash
ansible-playbook -i inventory.ini setup.yml
```

This will automatically install and configure on the VM:
- Docker container runtime
- Kubernetes single-node cluster
- Jenkins CI/CD server
- Helm package manager
- ArgoCD GitOps platform
- UFW firewall with proper rules

Takes about 10-15 minutes to complete.

**For detailed instructions:** See `platform/ansible/README.md`

### Step 4: Deploy the Banking API
Once Ansible finishes, the Jenkins and ArgoCD will be running on your VM. Push code changes to GitHub and they will automatically build and deploy via the CI/CD pipeline.

**For detailed instructions:** See `care-banking-api/README.md`

## Detailed Documentation

Each folder contains its own README with complete details:

- **platform/terraform/README.md** - Infrastructure setup, Azure credentials, deployment commands, and troubleshooting
- **platform/ansible/README.md** - What gets installed, configuration options, playbook structure, and verification steps
- **care-banking-api/README.md** - Application endpoints, deployment guide, API testing examples, and development tips

Start with these README files for in-depth information about each component.

## Technical Deep Dives by Topic

For specific technical concerns, refer to these resources:

| Concern | Location | Details |
|---------|----------|---------|
| Security & RBAC | care-banking-api/helm/templates/rbac/ | Service accounts, roles, role bindings for least privilege access |
| Network Security | care-banking-api/helm/templates/policies/ | Network policies, pod disruption budgets, resource quotas |
| Storage & Persistence | care-banking-api/helm/templates/storage/ | Persistent volumes, persistent volume claims configuration |
| High Availability | care-banking-api/helm/templates/advanced/ | Horizontal pod autoscaling, vertical pod autoscaling, priority classes |
| CI/CD Pipeline | care-banking-api/Jenkinsfile | 13-stage pipeline with security scans, testing, and deployment gates |
| Infrastructure as Code | platform/terraform/ | Azure resources, networking, security groups, monitoring configuration |
| Configuration Management | platform/ansible/ | Automated server setup, tool installation, security hardening |
| Container Configuration | care-banking-api/Dockerfile | Multi-stage build, security hardening, optimization |

## Project Structure

Read in this order: Terraform → Ansible → Care-Banking-Api

```
oncare-devops-task/
├── README.md
├── banking.md
│
├── platform/
│   ├── terraform/                    ← Start here: Creates cloud infrastructure
│   │   ├── README.md                 (See setup instructions)
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── secrets.tfvars
│   │   └── modules/
│   │       ├── azure-resource-group/
│   │       ├── azure-vnet/
│   │       ├── azure-vm/
│   │       └── azure-monitoring/
│   │
│   └── ansible/                      ← Then here: Configures the VM
│       ├── README.md                 (See configuration instructions)
│       ├── ansible.cfg
│       ├── inventory.ini
│       ├── setup.yml
│       ├── requirements.yml
│       ├── group_vars/
│       │   └── all.yml
│       ├── scripts/
│       ├── ARGOCD.md
│       └── CLEANUP_SUMMARY.md
│
└── care-banking-api/                 ← Finally: Deploy your application
    ├── README.md
    ├── Jenkinsfile                   (CI/CD pipeline)
    ├── Dockerfile                    (Container image)
    ├── deploy.sh
    ├── start.sh
    │
    ├── src/                          (Node.js/TypeScript source code)
    │   ├── index.ts
    │   ├── app.ts
    │   ├── config.ts
    │   ├── state.ts
    │   ├── adminRoutes.ts
    │   └── userRoutes.ts
    │
    ├── helm/                         (Kubernetes deployment configs)
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
    ├── package.json
    ├── pnpm-lock.yaml
    ├── tsconfig.json
    ├── config.json
    ├── .dockerignore
    ├── .gitignore
    ├── .prettierrc.yaml
    └── .prettierignore
```
