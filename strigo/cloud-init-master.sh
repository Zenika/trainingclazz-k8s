#!/bin/bash
apt-get remove docker docker-engine docker.io containerd runc
apt-get update
apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    socat \
    software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
apt-key fingerprint 0EBFCD88
add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io
docker run hello-world

mkdir -p /usr/local/bin/

sudo apt-get update && sudo apt-get install -y apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

#Generate password
echo "@kineZ" > /home/ubuntu/code-password

#Start code server
docker run -d --restart always -p 0.0.0.0:9999:8080 -e PASSWORD="$(cat /home/ubuntu/code-password)" -v "/home/ubuntu:/home/coder/project" -u "$(id -u ubuntu):$(id -g ubuntu)" codercom/code-server:latest

node_mane=master-0
hostname $node_mane
echo "127.0.0.1 $node_mane" >> /etc/hosts

git clone https://github.com/Zenika/trainingclazz-k8s.git  /home/ubuntu/lab

chown -R ubuntu:ubuntu /home/ubuntu/lab