# 🚀 ANSIBLE QUICK START - 3 Steps

## Step 1: Edit Configuration (2 files)

### File 1: `inventory.ini`
```ini
[servers]
ubuntu-server ansible_host=YOUR_IP_HERE ansible_user=ubuntu
```

### File 2: `group_vars/all.yml`
```yaml
devops_user: devops
ssh_public_key: "YOUR_SSH_PUBLIC_KEY_HERE"
```

---

## Step 2: Run Playbook

```bash
ansible-playbook setup.yml
```

---

## Step 3: Done! ✅

After ~15 minutes, you'll have:
- ✅ Docker
- ✅ Kubernetes (kubeadm, kubelet, kubectl)
- ✅ Helm
- ✅ Jenkins
- ✅ Devops user with SSH access
- ✅ Firewall configured
- ✅ Swap disabled
- ✅ NGINX test container

---

## 📝 Common Commands

```bash
# Test connection
ansible all -m ping

# Run playbook
ansible-playbook setup.yml

# Run with details
ansible-playbook setup.yml -v

# Check syntax
ansible-playbook setup.yml --syntax-check

# Dry run (no changes)
ansible-playbook setup.yml --check
```

---

## 🔧 After Installation

### Access Jenkins
```
URL: http://YOUR_IP:8080
Password: Check playbook output
```

### Initialize Kubernetes
```bash
ssh devops@YOUR_IP
sudo kubeadm init --pod-network-cidr=10.244.0.0/16
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
```

### Test NGINX
```bash
curl http://YOUR_IP:8888
```

---

## ❗ Troubleshooting

**Can't connect?**
```bash
ssh-copy-id ubuntu@YOUR_IP
```

**Playbook fails?**
```bash
ansible-playbook setup.yml -vvv
```

---

## 📂 Project Files

```
ansible/
├── setup.yml               ← Main playbook (run this)
├── inventory.ini           ← Edit: Add server IP
├── group_vars/all.yml      ← Edit: Add SSH key
├── ansible.cfg             ← Config (no changes needed)
└── README-SIMPLE.md        ← Instructions
```

---

**That's it! Simple and straightforward.** 🎉
