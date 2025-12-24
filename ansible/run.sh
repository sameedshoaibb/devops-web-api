#!/bin/bash
# Quick setup script

echo "Ansible Quick Setup"
echo "==================="
echo ""

# Check if files are configured
if grep -q "YOUR_SERVER_IP\|192.168.1.100" inventory.ini; then
    echo "⚠️  Please edit inventory.ini with your server IP"
    exit 1
fi

if grep -q "your-public-key-here" group_vars/all.yml; then
    echo "⚠️  Please edit group_vars/all.yml with your SSH public key"
    exit 1
fi

echo "✓ Configuration looks good"
echo ""
echo "Testing connectivity..."
ansible all -m ping || exit 1

echo ""
echo "Running playbook..."
ansible-playbook setup.yml

echo ""
echo "✓ Done!"
