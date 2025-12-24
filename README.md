# Ansible Infrastructure Setup - Simplified Version

## Overview

Simple Ansible automation to set up Ubuntu server for container orchestration and CI/CD.

## What Gets Installed

✅ System updates and essential packages  
✅ Docker CE  
✅ Kubernetes tools (kubeadm, kubelet, kubectl)  
✅ Helm  
✅ Jenkins  
✅ Non-root user with SSH access and sudo  
✅ UFW firewall  
✅ Swap disabled (for Kubernetes)  
✅ NGINX test container

## Quick Start

### 1. Prerequisites

- Ubuntu 20.04 or 22.04 server
- Ansible installed on your machine: `pip3 install ansible`
- SSH access to the server

### 2. Configure

Edit `inventory.ini` - Add your server IP:
```ini
[servers]
ubuntu-server ansible_host=YOUR_SERVER_IP ansible_user=ubuntu
```

Edit `group_vars/all.yml` - Add your SSH public key:
```yaml
ssh_public_key: "ssh-rsa AAAAB3NzaC... your-actual-key"
```

### 3. Run

```bash
# Test connectivity
ansible all -m ping

# Run the playbook
ansible-playbook setup.yml

# Run with verbose output
ansible-playbook setup.yml -v
```

## After Installation

### Initialize Kubernetes
```bash
ssh devops@YOUR_SERVER_IP
sudo kubeadm init --pod-network-cidr=10.244.0.0/16
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

### Access Jenkins
- URL: `http://YOUR_SERVER_IP:8080`
- Password: Displayed at end of playbook output

### Verify NGINX
```bash
curl http://YOUR_SERVER_IP:8888
```

## File Structure

```
ansible/
├── ansible.cfg          # Ansible configuration
├── inventory.ini        # Server inventory
├── setup.yml           # Main playbook (run this)
├── group_vars/
│   └── all.yml         # Variables
└── README-SIMPLE.md    # This file
```

## Troubleshooting

**Cannot connect to server:**
```bash
# Copy SSH key to server first
ssh-copy-id ubuntu@YOUR_SERVER_IP
```

**Playbook fails:**
```bash
# Run with verbose output
ansible-playbook setup.yml -vvv
```

## What's Different from Complex Version

**Removed:**
- Complex role structure (all tasks in one file)
- Extensive documentation
- Extra configuration options
- Pre-flight checks
- Makefile helpers
- Multiple inventory groups
- Advanced error handling

**Kept:**
- All required functionality
- Essential security (user, SSH, firewall)
- All required software installations
- Simple and easy to understand

## Support

For the complete version with advanced features, see the original role-based structure in the `roles/` directory.

---

**Execution Time**: ~10-15 minutes  
**Total Lines**: ~250 lines vs 1000+ in complex version
