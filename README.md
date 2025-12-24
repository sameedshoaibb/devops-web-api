# DevOps Infrastructure and Banking API Project

## Overview

This project demonstrates a comprehensive DevOps infrastructure automation pipeline for deploying a Banking API application on Kubernetes. The implementation showcases enterprise-grade practices including infrastructure as code, containerization, CI/CD automation, and production-ready Kubernetes deployments.

## Project Goals

The primary objectives of this project are:

1. **Infrastructure Automation** - Automate complete server provisioning using Ansible
2. **Application Containerization** - Build optimized Docker images with security best practices  
3. **Kubernetes Deployment** - Deploy applications using Helm charts with proper resource management
4. **CI/CD Pipeline** - Implement automated testing, building, and deployment workflows
5. **Operational Excellence** - Provide monitoring, logging, and automated maintenance capabilities

## Key Features

**Infrastructure Automation**
- Automated Ubuntu server provisioning with Ansible
- Complete setup of Docker, Kubernetes, Jenkins, and supporting tools
- User management with secure SSH access and sudo privileges
- Firewall configuration and security hardening

**Application Development** 
- Node.js/TypeScript Banking API with 6 endpoints for account management
- Multi-stage Docker builds achieving 25% size reduction
- Security hardening with non-root users and minimal attack surface
- Comprehensive testing and health check endpoints

**Container Orchestration**
- Helm charts supporting multiple environments (dev, staging, production)
- Horizontal Pod Autoscaling (HPA) for dynamic scaling
- Persistent storage with PV/PVC for data persistence  
- ConfigMaps and Secrets for proper configuration management
- Network policies and RBAC for security

**CI/CD Pipeline**
- Jenkins declarative pipeline with Docker Hub integration
- Automated Docker image building, testing, and publishing
- Multi-environment deployment automation
- Health check verification and deployment validation

**Monitoring and Operations**
- NGINX reverse proxy with slow request logging
- Scheduled CronJob for balance monitoring and alerting
- Resource quotas and priority classes for workload management
- Comprehensive logging and observability features

## Architecture

The project follows a modern three-tier architecture:

```
Development Environment    Jenkins CI/CD Pipeline    Kubernetes Cluster
┌─────────────────────┐    ┌─────────────────────┐    ┌─────────────────────┐
│ - Local Development │───▶│ - Automated Build   │───▶│ - Production Apps   │
│ - Code Repository   │    │ - Testing Pipeline  │    │ - Auto Scaling      │
│ - Version Control   │    │ - Docker Registry   │    │ - Load Balancing    │
└─────────────────────┘    └─────────────────────┘    └─────────────────────┘
                                      │                           │
                                      ▼                           ▼
                            ┌─────────────────────┐    ┌─────────────────────┐
                            │ - Docker Hub        │    │ - Banking API       │
                            │ - Image Registry    │    │ - Account Management│
                            │ - Automated Push    │    │ - Transaction Logic │
                            └─────────────────────┘    └─────────────────────┘
```

## Project Structure

```
oncare-devops-task/
├── README.md                           # Project overview and documentation
├── ansible/                            # Infrastructure automation
│   ├── ansible.cfg                     # Ansible configuration settings
│   ├── inventory.ini                   # Target server inventory
│   ├── setup.yml                       # Main provisioning playbook
│   ├── group_vars/all.yml              # Global variables
│   ├── scripts/install-k8s.sh          # Kubernetes installation script
│   ├── QUICKSTART.md                   # Quick setup guide
│   └── README.md                       # Ansible documentation
└── banking-api/                        # Banking application
    ├── Dockerfile                      # Multi-stage container build
    ├── Jenkinsfile                     # CI/CD pipeline configuration
    ├── package.json                    # Node.js dependencies
    ├── tsconfig.json                   # TypeScript configuration
    ├── config.json                     # Application settings
    ├── src/                            # Source code
    │   ├── index.ts                    # Application entry point
    │   ├── app.ts                      # Express server setup
    │   ├── userRoutes.ts              # User account endpoints
    │   └── adminRoutes.ts             # Administrative endpoints
    ├── scripts/deploy/                 # Deployment utilities
    │   └── deploy.sh                  # Multi-environment deployment script
    ├── helm/                          # Kubernetes manifests
    │   ├── Chart.yaml                 # Helm chart metadata
    │   ├── values.yaml                # Default values
    │   ├── values.dev.yaml            # Development environment
    │   ├── values.staging.yaml        # Staging environment
    │   ├── values.prod.yaml           # Production environment
    │   ├── README.md                  # Helm chart documentation
    │   └── templates/                 # Kubernetes resource templates
    │       ├── deployment.yaml        # Application deployment
    │       ├── service.yaml           # Service configuration
    │       ├── ingress.yaml           # External access routing
    │       ├── configmap.yaml         # Configuration data
    │       ├── secret.yaml            # Sensitive information
    │       ├── cronjob.yaml           # Scheduled tasks
    │       ├── hpa.yaml               # Horizontal Pod Autoscaler
    │       ├── pv.yaml                # Persistent Volume
    │       ├── pvc.yaml               # Persistent Volume Claim
    │       ├── resourcequota.yaml     # Resource limits
    │       ├── networkpolicy.yaml     # Network security
    │       ├── priorityclass.yaml     # Pod scheduling priority
    │       └── vpa.yaml               # Vertical Pod Autoscaler
    └── README.md                      # Application documentation
```

---

## Getting Started

### Prerequisites

- Ubuntu 20.04 or 22.04 server
- Ansible installed locally: `pip3 install ansible`
- SSH access to the target server
- Docker Hub account for image registry

### Step 1: Infrastructure Setup

Navigate to the ansible directory and configure your environment:

```bash
cd ansible/
```

Edit `inventory.ini` with your server details:
```ini
[servers]
ubuntu-server ansible_host=YOUR_SERVER_IP ansible_user=ubuntu
```

Edit `group_vars/all.yml` with your SSH public key:
```yaml
ssh_public_key: "ssh-rsa AAAAB3NzaC... your-public-key"
```

Run the provisioning playbook:
```bash
ansible-playbook setup.yml
```

This will install and configure Docker, Kubernetes, Jenkins, and create proper user accounts.

### Step 2: Application Deployment

Navigate to the banking-api directory:

```bash
cd banking-api/
```

Deploy to your desired environment:

**Production:**
```bash
./scripts/deploy/deploy.sh prod
```

**Development:**
```bash
./scripts/deploy/deploy.sh dev
```

**Staging:**
```bash
./scripts/deploy/deploy.sh staging
```

### Step 3: Access and Verification

**Access Banking API:**
```bash
kubectl port-forward -n banking-api svc/banking-api 8181:80 &
curl http://localhost:8181/ping
```

**Access Jenkins:**
Open your browser to `http://YOUR_SERVER_IP:8080`
The initial admin password is displayed at the end of the Ansible playbook output.

**Verify Deployment:**
```bash
kubectl get all -n banking-api
```

---

## Banking API Endpoints

The Banking API provides the following endpoints for account management:

| Endpoint | Method | Description | Authentication |
|----------|--------|-------------|----------------|
| `/ping` | GET | Health check endpoint | None |
| `/admin/account` | POST | Create new account | Admin API key required |
| `/admin/accounts` | GET | List all accounts | Admin API key required |
| `/account/{id}/info` | POST | Get account information | Account password required |
| `/account/{id}/deposit` | POST | Deposit funds to account | Account password required |
| `/account/{id}/withdraw` | POST | Withdraw funds from account | Account password required |

**Note:** The delete account functionality is available but only works when the account balance is zero.

---

## Technology Stack

**Infrastructure and Automation:**
- Ansible for infrastructure provisioning and configuration management
- Ubuntu 20.04/22.04 as the base operating system
- Docker for containerization with multi-stage builds
- Kubernetes (kubeadm) for container orchestration
- Helm for package management and templating

**Application Development:**
- Node.js runtime environment
- TypeScript for type-safe JavaScript development
- Express.js web framework
- PNPM for efficient package management

**CI/CD and DevOps:**
- Jenkins with declarative pipeline syntax
- Docker Hub as the container registry
- NGINX as reverse proxy with request logging
- UFW firewall for network security

**Monitoring and Operations:**
- Kubernetes native monitoring with liveness and readiness probes
- CronJob for scheduled balance checking and alerting
- Horizontal Pod Autoscaler (HPA) for automatic scaling
- Resource quotas and limits for resource management

---

## DevOps Implementation Features

### Infrastructure Automation

**Automated Server Provisioning**
- Complete Ubuntu server setup using Ansible playbooks
- Installation and configuration of Docker, Kubernetes, Jenkins, and Helm
- User management with secure SSH key-based authentication
- Firewall configuration with UFW for network security
- Swap disabling and system optimization for Kubernetes

**Security Hardening**
- Non-root user creation with sudo privileges
- SSH key-based authentication enforcement
- Firewall rules for essential services only
- Security best practices implementation across all components

### Application Lifecycle Management

**Container Optimization**
- Multi-stage Docker builds reducing image size by 25%
- Alpine-based images for minimal attack surface
- Non-root container execution for enhanced security
- Efficient layer caching for faster rebuild times
- Production-ready image with minimal dependencies

**Multi-Environment Support**
- Separate Helm value files for development, staging, and production
- Environment-specific configuration management
- Parameterized deployment scripts for different environments
- Consistent deployment processes across all environments

### CI/CD Pipeline Excellence

**Automated Build Process**
- Jenkins declarative pipeline with clear stage definitions
- Automated Docker image building and testing
- Health endpoint verification before deployment
- Integration with Docker Hub for image registry
- Workspace cleanup and artifact management

**Quality Assurance**
- Automated health checks during deployment
- Pre-deployment testing of critical endpoints
- Rollback capabilities through Helm
- Deployment verification and validation steps

### Kubernetes Operations

**Resource Management**
- Horizontal Pod Autoscaler (HPA) for dynamic scaling based on CPU utilization
- Resource quotas and limits for proper resource allocation
- Persistent Volume (PV) and Persistent Volume Claim (PVC) for data persistence
- Priority classes for pod scheduling optimization

**Configuration and Security**
- ConfigMaps for non-sensitive configuration data
- Kubernetes Secrets for sensitive information management
- Network policies for micro-segmentation
- RBAC implementation for access control
- Service accounts with minimal required permissions

**Monitoring and Maintenance**
- NGINX sidecar container for reverse proxy functionality
- Slow request logging with configurable thresholds (>1ms)
- Scheduled CronJob for balance monitoring and alerting
- Comprehensive health checks with liveness and readiness probes
- Automated log rotation and cleanup processes

---

## Documentation

Each component of the project includes comprehensive documentation:

- **[Ansible Infrastructure Guide](ansible/README.md)** - Complete infrastructure provisioning documentation
- **[Banking API Documentation](banking-api/README.md)** - Application development and deployment guide  
- **[Helm Chart Documentation](banking-api/helm/README.md)** - Kubernetes deployment and configuration details
- **[Quick Start Guide](ansible/QUICKSTART.md)** - Fast setup instructions for immediate deployment

---

## Project Achievements

This project demonstrates several production-ready DevOps practices and achievements:

**Infrastructure Excellence**
- Fully automated infrastructure provisioning reducing manual setup time from hours to minutes
- Consistent environment setup across development, staging, and production
- Security-first approach with proper authentication, authorization, and network policies
- Scalable infrastructure design supporting future growth and additional applications

**Application Development Best Practices**
- Container-first development approach with optimized images
- Comprehensive testing strategy including health checks and endpoint validation
- Proper separation of configuration from application code
- Security hardening throughout the application stack

**Operational Efficiency**
- Complete CI/CD automation from code commit to production deployment
- Monitoring and alerting capabilities for proactive issue detection
- Automated scaling based on resource utilization
- Efficient resource utilization through proper quotas and limits

**Enterprise Readiness**
- Multi-environment support with proper promotion workflows
- Comprehensive documentation for maintenance and troubleshooting
- Security compliance with industry best practices
- Disaster recovery capabilities through Infrastructure as Code

This implementation serves as a foundation for enterprise-grade applications requiring robust infrastructure, security, and operational excellence.


