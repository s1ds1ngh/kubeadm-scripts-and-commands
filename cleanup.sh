#!/bin/bash

sudo kubeadm reset --cri-socket unix:///var/run/crio/crio.sock

# Stop and disable CRI-O (if installed)
if systemctl list-unit-files | grep -q 'crio.service'; then
    sudo systemctl stop crio
    sudo systemctl disable crio
fi

# Remove CRI-O (if installed)
if dpkg -l | grep -q 'cri-o'; then
    sudo apt-get purge -y cri-o
fi

# Remove CRI-O repository
sudo rm -f /etc/apt/keyrings/cri-o-apt-keyring.gpg
sudo rm -f /etc/apt/sources.list.d/cri-o.list

# Remove Kubernetes packages (including held packages)
sudo apt-get purge -y --allow-change-held-packages kubelet kubeadm kubectl

# Remove Kubernetes repository
sudo rm -f /etc/apt/keyrings/kubernetes-apt-keyring.gpg
sudo rm -f /etc/apt/sources.list.d/kubernetes.list

# Remove jq (if installed)
sudo apt-get purge -y jq

# Remove the kubelet configuration
sudo rm -f /etc/default/kubelet

# Remove the sysctl configuration
sudo rm -f /etc/sysctl.d/k8s.conf

# Remove the modules configuration
sudo rm -f /etc/modules-load.d/k8s.conf

# Stop Docker or other container runtimes using the overlay module
if systemctl list-unit-files | grep -q 'docker.service'; then
    sudo systemctl stop docker
fi

# Unload the kernel modules
sudo modprobe -r overlay || echo "Overlay module is in use and cannot be unloaded. Stop any container runtimes and try again."
sudo modprobe -r br_netfilter

# Re-enable swap
sudo swapon -a

# Remove the swapoff cron job
crontab -l | grep -v '/sbin/swapoff -a' | crontab -

# Clean up any remaining dependencies
sudo apt-get autoremove -y
sudo apt-get autoclean -y

echo "Cleanup complete. You can now run the original script again from scratch."
