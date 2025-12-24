# Continuous Deployment Pipeline

## Overview

The CD pipeline runs on Pull Requests to `main`, `staging`, or `dev` branches. It automates:
- Docker image building and signing
- Security scanning of container images
- Artifact management (SBOM generation)
- Deployment configuration updates

**Pipeline Trigger:** Pull Request to `main`, `staging`, or `dev`

---

## Environment Configuration

| Branch | Environment | Namespace | Configuration |
|--------|-------------|-----------|----------------|
| `main` | Production | banking-prod | Helm production values |
| `staging` | Staging | banking-staging | Helm staging values |
| `dev` | Development | banking-dev | Helm dev values |

---

## Pipeline Stages

### Stage 1: Build & Test
Prepares the codebase for deployment:
- Install dependencies
- Run unit tests
- Compile TypeScript to JavaScript
- Scan for vulnerabilities

### Stage 2: Build & Sign Image
Creates and secures the Docker image:
- Build Docker image with optimized multi-stage build
- Push to container registry
- Sign image with Cosign for integrity verification
- Generate Software Bill of Materials (SBOM)

### Stage 3: Scan Image
Validates security of the container image:
- Scan for known vulnerabilities
- Upload results to GitHub Security tab
- Fail pipeline if critical vulnerabilities found

### Stage 4: Update Deployment Config
Automates the deployment process:
- Determine target environment from branch name
- Update Helm values file with new image version
- Commit and push configuration changes
- ArgoCD will detect changes and will trigger automated deployment

---

## Key Features

- **Security-Focused** - Image signing with Cosign and vulnerability scanning
- **Automated Deployment** - Configuration updated automatically after successful builds
- **Artifact Tracking** - SBOM generation for supply chain security
- **Environment-Aware** - Different configurations per branch/environment
- **GitHub Integrated** - Security results visible in GitHub UI

---