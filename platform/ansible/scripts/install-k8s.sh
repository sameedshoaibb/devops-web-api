#!/bin/bash

[[ $EUID -ne 0 ]] && echo "Run as root" && exit 1

PRIVATE_IP=$(hostname -I | awk '{print $1}')

# Check if cluster is already initialized
if [ -f /etc/kubernetes/admin.conf ]; then
    echo "Kubernetes cluster already initialized. Skipping init."
    export KUBECONFIG=/etc/kubernetes/admin.conf
    kubectl get nodes
    exit 0
fi

# Configure containerd
mkdir -p /etc/containerd
containerd config default > /etc/containerd/config.toml
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
systemctl restart containerd

# Kernel modules
modprobe overlay
modprobe br_netfilter
cat <<EOF > /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward = 1
EOF
sysctl --system > /dev/null

# Initialize cluster
kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=$PRIVATE_IP

# Configure kubectl
mkdir -p /root/.kube
cp /etc/kubernetes/admin.conf /root/.kube/config

if [ -n "$SUDO_USER" ]; then
    USER_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)
    mkdir -p "$USER_HOME/.kube"
    cp /etc/kubernetes/admin.conf "$USER_HOME/.kube/config"
    chown -R "$SUDO_USER:$SUDO_USER" "$USER_HOME/.kube"
fi

if id "devops" &>/dev/null; then
    mkdir -p /home/devops/.kube
    cp /etc/kubernetes/admin.conf /home/devops/.kube/config
    chown -R devops:devops /home/devops/.kube
fi

# Install Flannel CNI
export KUBECONFIG=/etc/kubernetes/admin.conf
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml

# Remove taint for single-node
kubectl taint nodes --all node-role.kubernetes.io/control-plane- 2>/dev/null || true

echo "Done. Waiting 30s..."
sleep 30
kubectl get nodes
kubectl get pods -A
