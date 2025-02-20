#!/bin/bash

# Initialize the Kubernetes cluster with specified options
echo "Initializing Kubernetes cluster..."
sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --cri-socket unix:///var/run/crio/crio.sock

# Set up the kubeconfig for the user
echo "Setting up kubeconfig..."
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Apply the Flannel CNI
echo "Applying Flannel CNI..."
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml

# Generate the join command
echo "Generating the kubeadm join command..."
echo "Copy this command below and run it on the slave nodes to connect them to the master node"
kubeadm token create --print-join-command

