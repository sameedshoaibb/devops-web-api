# Azure Infrastructure with Terraform

## Purpose

This Terraform configuration creates a single Ubuntu VM on Azure that will be configured by Ansible playbooks to become your complete DevOps platform. The machine will be set up with:

- **Docker** - Container runtime
- **Kubernetes** - Container orchestration (single-node cluster)
- **Jenkins** - CI/CD pipeline automation
- **Helm** - Kubernetes package manager
- **ArgoCD** - GitOps continuous deployment
- **UFW Firewall** - Network security with configured ports

Think of Terraform as building the infrastructure, and Ansible as configuring what runs on it.

## What Terraform Creates

- **Ubuntu 22.04 LTS VM**: Standard_D4ls_v5 instance ready for Ansible to configure
- **Virtual Network**: 10.0.0.0/16 with subnet 10.0.1.0/24
- **Security Rules**: SSH, Jenkins (8080), Nginx (8888), ArgoCD (30080), GitHub webhooks
- **Monitoring**: CPU alerts when usage > 80%
- **Public IP**: Static IP to access your machine

## Quick Start

### Step 1: Configure Azure Credentials

Edit `secrets.tfvars` with your Azure account details:

```
subscription_id = "your-subscription-id"
tenant_id       = "your-tenant-id"
client_id       = "your-client-id"
client_secret   = "your-client-secret"
location        = "UK West"
infra_cidr      = "10.0.1.0/24"
```

### Step 2: Initialize Terraform

```bash
cd platform/terraform
terraform init
```

This downloads Terraform providers and sets up the working directory.

### Step 3: Review Changes

```bash
terraform plan -var-file=secrets.tfvars
```

This shows exactly what will be created before you apply it.

### Step 4: Create Infrastructure

```bash
terraform apply -var-file=secrets.tfvars -auto-approve
```

This creates all Azure resources. Takes about 5-10 minutes.

### Step 5: Configure with Ansible (Next Step)

Once complete, go to `platform/ansible` folder and follow the Ansible README to configure the VM with Docker, Kubernetes, Jenkins, and ArgoCD.

## Useful Terraform Commands

```bash
# See what will be created
terraform plan -var-file=secrets.tfvars

# Apply changes
terraform apply -var-file=secrets.tfvars -auto-approve

# Destroy everything (careful!)
terraform destroy -var-file=secrets.tfvars -auto-approve

# Show current resources
terraform show

# Get output values (like VM IP address)
terraform output
```

## After Deployment

When Terraform finishes, you'll have:

1. **VM Public IP** - Get it with: `terraform output`
2. **Admin Username** - `sameed` (change in variables.tf if needed)
3. **SSH Access** - Use your private key to connect via SSH

Then proceed to the Ansible folder to automatically install and configure all DevOps tools on this machine.

## Troubleshooting

**"Resource already exists"?** 
Resources from a previous run still exist in Azure. Either delete them manually or import them into Terraform state.

**Need to change location?**
Edit `location` in `secrets.tfvars` or `variables.tf` (default: UK West)

**Want to see what will change?**
Run `terraform plan -var-file=secrets.tfvars` before applying anything.
