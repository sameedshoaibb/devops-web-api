# Ansible Infrastructure Setup

## Overview

This Ansible playbook automates the complete setup of an Ubuntu server for container orchestration and CI/CD operations. The playbook installs and configures Docker, Kubernetes, Jenkins, and Helm while implementing security best practices and creating proper user accounts for automation workflows.

## What Gets Installed

The playbook installs and configures the following components:

**System Components:**
- System updates and essential packages
- Docker CE with proper group permissions
- Kubernetes tools (kubeadm, kubelet, kubectl)
- Helm package manager
- Jenkins CI/CD server
- ArgoCD GitOps platform

**Security and User Management:**
- Non-root user with SSH access and sudo privileges
- UFW firewall with configured ports
- Swap disabled (required for Kubernetes)
- SSH key-based authentication

**GitOps and Automation:**
- ArgoCD for continuous deployment
- Jenkins for CI/CD pipelines
- Automated GitOps workflow setup
- Multi-environment deployment capability

**Testing and Verification:**
- NGINX test container for Docker verification
- Kubernetes cluster initialization
- Service validation checks

## Why Use Ansible

Manual server setup involves running dozens of commands, waiting for downloads, and managing complex configuration steps. Ansible automates this entire process through infrastructure as code, providing:

- **Consistency** - Same configuration every time
- **Reproducibility** - Easy to replicate across multiple servers
- **Documentation** - Configuration is self-documenting
- **Error Recovery** - Can re-run playbook to fix issues
- **Time Savings** - Reduces setup time from hours to minutes

## Project Structure

```
ansible/
├── ansible.cfg              # Ansible configuration settings
├── inventory.ini            # Target server definitions
├── setup.yml               # Main provisioning playbook
├── requirements.yml         # Ansible collection requirements
├── group_vars/
│   └── all.yml             # Global variables and settings
├── scripts/
│   └── install-k8s.sh      # Kubernetes cluster initialization
├── commands.txt            # Manual command reference
├── QUICKSTART.md           # Quick setup guide
├── ARGOCD.md               # ArgoCD setup and usage guide
└── README.md               # This documentation
├── QUICKSTART.md           # Quick setup guide
└── README.md               # This documentation
```

---

## Getting Started

### Prerequisites

Before running this playbook, ensure you have:

- Ubuntu 20.04 or 22.04 target server
- Ansible installed on your local machine: `pip3 install ansible`
- SSH access to the target server
- sudo privileges on the target server

### Install Required Collections

Install the required Ansible collections:

```bash
ansible-galaxy collection install -r requirements.yml
```

Or install individually:
```bash
ansible-galaxy collection install kubernetes.core
```

### Configuration

Edit `inventory.ini` with your server details:

```ini
[servers]
ubuntu-server ansible_host=YOUR_SERVER_IP ansible_user=ubuntu
```

Edit `group_vars/all.yml` with your SSH public key:

```yaml
ssh_public_key: "ssh-rsa AAAAB3NzaC... your-actual-key"
```

### Execution

Test connectivity to your server:

```bash
ansible all -m ping
```

Run the main provisioning playbook:

```bash
ansible-playbook setup.yml
```

For detailed output during execution:

```bash
ansible-playbook setup.yml -v
```

---

## Installation Components

The playbook executes the following tasks in sequence:

### System Preparation
1. **System Update** - Updates all packages to latest versions
2. **Essential Packages** - Installs curl, wget, git, and other utilities
3. **User Management** - Creates devops user with sudo access and SSH key authentication

### Container Platform
4. **Docker Installation** - Installs Docker CE with proper group permissions
5. **Kubernetes Tools** - Installs kubeadm, kubelet, kubectl (v1.28)
6. **Helm Installation** - Package manager for Kubernetes applications

### CI/CD Platform
7. **Jenkins Setup** - Installs Jenkins CI/CD server on port 8080
8. **Jenkins Configuration** - Creates jenkins user with Kubernetes access

### Security and Networking
9. **Firewall Configuration** - Configures UFW with necessary ports (22, 80, 443, 6443, 8080, 10250, 8888)
10. **Swap Disable** - Disables swap (required for Kubernetes)

### Verification
11. **Docker Test** - Runs NGINX container on port 8888 to verify Docker functionality
12. **Kubernetes Initialization** - Sets up single-node cluster with Flannel networking

---

## Post-Installation Steps

### Initialize Kubernetes Cluster

SSH into your server and initialize Kubernetes:

```bash
ssh devops@YOUR_SERVER_IP
sudo kubeadm init --pod-network-cidr=10.244.0.0/16
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

### Access Jenkins

Access Jenkins web interface:
- URL: `http://YOUR_SERVER_IP:8080`
- Initial admin password: Displayed at end of playbook output

### Verify Docker Installation

Test Docker functionality:

```bash
curl http://YOUR_SERVER_IP:8888
```

Expected response: NGINX welcome page

---



### Run the Playbook### Verify NGINX

```bash

```bashcurl http://YOUR_SERVER_IP:8888

cd ansible```

ansible-playbook setup.yml

```## File Structure



This takes about 5-10 minutes depending on your server and internet speed.```

ansible/

### Verify Everything Works├── ansible.cfg          # Ansible configuration

├── inventory.ini        # Server inventory

After the playbook finishes:├── setup.yml           # Main playbook (run this)

├── group_vars/

```bash│   └── all.yml         # Variables

# SSH to your server└── README-SIMPLE.md    # This file

ssh -i ~/.ssh/your_key your_user@YOUR_SERVER_IP```


## Verification

After the playbook completes successfully, verify the installation:

### Check System Services

SSH to your server and verify services:

```bash
ssh devops@YOUR_SERVER_IP

# Check Kubernetes
kubectl get nodes
kubectl get pods -A

# Check Docker
docker ps

# Check Jenkins status
systemctl status jenkins
```

### Test Network Connectivity

Verify that all services are accessible:

```bash
# Test Docker (NGINX container)
curl http://YOUR_SERVER_IP:8888

# Test Jenkins web interface
curl http://YOUR_SERVER_IP:8080
```

---

## User Management

The playbook creates two user accounts with different purposes:

**Primary User (ubuntu/sameed)**
- Used for interactive work and running Ansible
- Has sudo privileges and SSH access
- Used for manual server administration

**DevOps User (devops)**  
- Created specifically for CI/CD pipelines and automation
- Has Docker and Kubernetes access
- Used by Jenkins and automated scripts
- Includes kubeconfig for cluster access

Both users have sudo access and can run kubectl commands. This separation maintains security by isolating automated processes from interactive sessions.

## Network Configuration

The server configuration includes these network components:

**Server Networking**
- Server IP: Your VM private IP (assigned by cloud provider)
- Pod Network: 10.244.0.0/16 (Flannel CNI)
- Service Network: 10.96.0.0/12 (Kubernetes default)

**Firewall Rules**
- SSH (22): For remote access
- HTTP (80): For web applications  
- HTTPS (443): For secure web traffic
- Kubernetes API (6443): For cluster communication
- Jenkins (8080): For CI/CD web interface
- Kubelet (10250): For Kubernetes node communication
- Test NGINX (8888): For Docker verification

---

## Troubleshooting

### Connection Issues

**Cannot connect to server:**

```bash
# Copy SSH key to server first
ssh-copy-id ubuntu@YOUR_SERVER_IP

# Test SSH connection manually
ssh -i ~/.ssh/your_key ubuntu@YOUR_SERVER_IP

# Then test Ansible connectivity
ansible all -m ping
```

### Playbook Execution Issues

**Playbook fails during execution:**

```bash
# Run with verbose output for debugging
ansible-playbook setup.yml -vvv

# Check specific task failure
ansible-playbook setup.yml --start-at-task="task_name"
```

### Service Issues

**Jenkins not accessible:**

```bash
# Check Jenkins status
systemctl status jenkins

# Check firewall rules
sudo ufw status

# Check Jenkins logs
sudo journalctl -u jenkins
```

**Kubernetes cluster issues:**

```bash
# Check cluster status
kubectl cluster-info

# Check node status
kubectl get nodes -o wide

# Check kubelet logs
sudo journalctl -xeu kubelet | tail -50

# Check pod events
kubectl describe pod <pod-name> -n kube-system
```

**Need to start over:**

```bash
# Reset Kubernetes cluster
sudo kubeadm reset -f
sudo rm -rf /etc/cni/net.d ~/.kube /var/lib/etcd

# Re-run playbook
ansible-playbook setup.yml
```

---

## Implementation Overview

This simplified implementation focuses on core functionality while maintaining production readiness:

**Files Reference**

| File | Purpose |
|------|---------|
| `setup.yml` | Main playbook with all provisioning tasks |
| `inventory.ini` | Defines target servers and connection details |
| `group_vars/all.yml` | Variables and configuration settings |
| `ansible.cfg` | Ansible behavior and connection settings |
| `scripts/install-k8s.sh` | Kubernetes cluster initialization script |
| `commands.txt` | Manual command reference for understanding |

**Services After Installation**

| Service | Port | Access Method |
|---------|------|---------------|
| SSH | 22 | `ssh user@server_ip` |
| Jenkins | 8080 | `http://server_ip:8080` |
| Kubernetes API | 6443 | Internal cluster communication |
| Test NGINX | 8888 | `http://server_ip:8888` |

**Key Achievements**
- Execution Time: 10-15 minutes for complete setup
- Single playbook approach for simplicity
- All required functionality maintained
- Essential security configurations included
- Production-ready service installations

This implementation provides the foundation for deploying containerized applications with proper CI/CD automation while remaining accessible and maintainable for DevOps teams.
