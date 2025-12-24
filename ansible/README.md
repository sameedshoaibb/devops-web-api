# Ansible Infrastructure Setup# Ansible Infrastructure Setup - Simplified Version



## What This Does## Overview



This Ansible playbook prepares an Ubuntu server for running containerized applications with Kubernetes. It handles all the tedious setup work so you can focus on deploying your apps.Simple Ansible automation to set up Ubuntu server for container orchestration and CI/CD.



The playbook installs Docker, Kubernetes tools, Helm, and Jenkins. It also creates a dedicated user for automation, configures the firewall, and initializes a single-node Kubernetes cluster.## What Gets Installed



## Why Ansible✅ System updates and essential packages  

✅ Docker CE  

Setting up a server manually means running dozens of commands, waiting for downloads, and hoping you did not miss a step. Ansible automates all of this. You run one command and walk away. If something breaks later, you can run the same playbook again to fix it.✅ Kubernetes tools (kubeadm, kubelet, kubectl)  

✅ Helm  

## Folder Structure✅ Jenkins  

✅ Non-root user with SSH access and sudo  

```✅ UFW firewall  

ansible/✅ Swap disabled (for Kubernetes)  

├── ansible.cfg           # Connection settings (timeout, SSH options)✅ NGINX test container

├── inventory.ini         # Server IP and SSH credentials

├── setup.yml             # Main playbook with all tasks## Quick Start

├── group_vars/

│   └── all.yml           # Variables (username, SSH key, ports)### 1. Prerequisites

├── scripts/

│   └── install-k8s.sh    # Kubernetes cluster init script- Ubuntu 20.04 or 22.04 server

├── commands.txt          # Step-by-step manual reference- Ansible installed on your machine: `pip3 install ansible`

└── README.md             # This file- SSH access to the server

```

### 2. Configure

## What Gets Installed

Edit `inventory.ini` - Add your server IP:

The playbook runs these tasks in order:```ini

[servers]

1. **System Update** - Updates all packages to latest versionsubuntu-server ansible_host=YOUR_SERVER_IP ansible_user=ubuntu

2. **Devops User** - Creates a non-root user with sudo access and your SSH key```

3. **Docker** - Installs Docker CE for running containers

4. **Kubernetes Tools** - Installs kubeadm, kubelet, kubectl (v1.28)Edit `group_vars/all.yml` - Add your SSH public key:

5. **Helm** - Package manager for Kubernetes```yaml

6. **Jenkins** - CI/CD server on port 8080ssh_public_key: "ssh-rsa AAAAB3NzaC... your-actual-key"

7. **Firewall** - Opens only necessary ports (22, 80, 443, 6443, 8080, 10250, 8888)```

8. **Swap Off** - Disables swap (required by Kubernetes)

9. **Test Container** - Runs nginx on port 8888 to verify Docker works### 3. Run

10. **Kubernetes Cluster** - Initializes a single-node cluster with Flannel networking

```bash

## How to Use# Test connectivity

ansible all -m ping

### Prerequisites

# Run the playbook

You need Ansible on your local machine and SSH access to your server.ansible-playbook setup.yml



```bash# Run with verbose output

pip3 install ansibleansible-playbook setup.yml -v

``````



### Configure Your Server## After Installation



Edit `inventory.ini` with your server details:### Initialize Kubernetes

```bash

```inissh devops@YOUR_SERVER_IP

[servers]sudo kubeadm init --pod-network-cidr=10.244.0.0/16

myserver ansible_host=YOUR_SERVER_IP ansible_user=YOUR_USERNAME ansible_ssh_private_key_file=~/.ssh/your_keymkdir -p $HOME/.kube

```sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config

sudo chown $(id -u):$(id -g) $HOME/.kube/config

Edit `group_vars/all.yml` with your SSH public key:```



```yaml### Access Jenkins

ssh_public_key: "ssh-ed25519 AAAA... your-email@example.com"- URL: `http://YOUR_SERVER_IP:8080`

```- Password: Displayed at end of playbook output



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



# Check Kubernetes## Troubleshooting

kubectl get nodes

kubectl get pods -A**Cannot connect to server:**

```bash

# Check Docker# Copy SSH key to server first

docker psssh-copy-id ubuntu@YOUR_SERVER_IP

```

# Check Jenkins (note the password from playbook output)

curl http://YOUR_SERVER_IP:8080**Playbook fails:**

``````bash

# Run with verbose output

## The Two Usersansible-playbook setup.yml -vvv

```

The playbook creates a user called `devops`. Here is why:

## What's Different from Complex Version

- **Your user** (sameed, ubuntu, etc) - For interactive work and running Ansible

- **devops user** - For CI/CD pipelines and automation scripts**Removed:**

- Complex role structure (all tasks in one file)

Both users have sudo access and can run kubectl. The separation keeps your personal environment clean.- Extensive documentation

- Extra configuration options

## Network Setup- Pre-flight checks

- Makefile helpers

The server uses these networks:- Multiple inventory groups

- Advanced error handling

- **Server IP** - Your VM private IP (e.g., 10.0.0.4)

- **Pod Network** - 10.244.0.0/16 (Flannel CNI)**Kept:**

- **Service Network** - 10.96.0.0/12 (Kubernetes default)- All required functionality

- Essential security (user, SSH, firewall)

If you are on Azure, AWS, or GCP, the playbook auto-detects your private IP. Do not use the public IP for Kubernetes init.- All required software installations

- Simple and easy to understand

## Troubleshooting

## Support

**Ansible cannot connect:**

```bashFor the complete version with advanced features, see the original role-based structure in the `roles/` directory.

# Test SSH manually first

ssh -i ~/.ssh/your_key your_user@YOUR_SERVER_IP---



# Then test Ansible**Execution Time**: ~10-15 minutes  

ansible all -m ping**Total Lines**: ~250 lines vs 1000+ in complex version

```

**Kubernetes pods not starting:**
```bash
# Check kubelet logs
sudo journalctl -xeu kubelet | tail -50

# Check pod events
kubectl describe pod <pod-name> -n kube-system
```

**Need to start over:**
```bash
# Reset Kubernetes
sudo kubeadm reset -f
sudo rm -rf /etc/cni/net.d ~/.kube /var/lib/etcd

# Re-run playbook
ansible-playbook setup.yml
```

## Files Reference

| File | Purpose |
|------|---------|
| `setup.yml` | Main playbook, runs all tasks |
| `inventory.ini` | Defines which servers to configure |
| `group_vars/all.yml` | Variables used by the playbook |
| `ansible.cfg` | Ansible behavior settings |
| `scripts/install-k8s.sh` | Shell script for cluster init |
| `commands.txt` | Manual commands if you want to understand each step |

## Services After Install

| Service | Port | Access |
|---------|------|--------|
| SSH | 22 | `ssh user@server` |
| Jenkins | 8080 | `http://server:8080` |
| Kubernetes API | 6443 | Internal only |
| Test NGINX | 8888 | `http://server:8888` |

## Next Steps

After this playbook completes, your server is ready for:

- Part 2: Containerize the banking-api with Docker
- Part 3: Deploy to Kubernetes with Helm
- Part 4: Set up Jenkins CI/CD pipeline
- Part 5: Configure secrets management
