#!/bin/bash

echo -e " \033[33;2m                    ___           ___           ___           ___           ___           ___           ___     \033[0m"
echo -e " \033[33;2m                   /  /\         /__/\         /  /\         /__/\         /  /\         /  /\         /__/\    \033[0m"
echo -e " \033[33;2m                  /  /::\        \  \:\       /  /:/_        \  \:\       /  /::\       /  /::\        \  \:\   \033[0m"
echo -e " \033[33;2m  ___     ___    /  /:/\:\        \  \:\     /  /:/ /\        \__\:\     /  /:/\:\     /  /:/\:\        \  \:\  \033[0m"
echo -e " \033[33;2m /__/\   /  /\  /  /:/  \:\   _____\__\:\   /  /:/_/::\   ___ /  /::\   /  /:/  \:\   /  /:/~/:/    _____\__\:\ \033[0m"
echo -e " \033[33;2m \  \:\ /  /:/ /__/:/ \__\:\ /__/::::::::\ /__/:/__\/\:\ /__/\  /:/\:\ /__/:/ \__\:\ /__/:/ /:/___ /__/::::::::\\033[0m"
echo -e " \033[33;2m  \  \:\  /:/  \  \:\ /  /:/ \  \:\~~\~~\/ \  \:\ /~~/:/ \  \:\/:/__\/ \  \:\ /  /:/ \  \:\/:::::/ \  \:\~~\~~\/\033[0m"
echo -e " \033[33;2m   \  \:\/:/    \  \:\  /:/   \  \:\  ~~~   \  \:\  /:/   \  \::/       \  \:\  /:/   \  \::/~~~~   \  \:\  ~~~ \033[0m"
echo -e " \033[33;2m    \  \::/      \  \:\/:/     \  \:\        \  \:\/:/     \  \:\        \  \:\/:/     \  \:\        \  \:\     \033[0m"
echo -e " \033[33;2m     \__\/        \  \::/       \  \:\        \  \::/       \  \:\        \  \::/       \  \:\        \  \:\    \033[0m"
echo -e " \033[33;2m                   \__\/         \__\/         \__\/         \__\/         \__\/         \__\/         \__\/    \033[0m"
echo -e " \033[33;2m                                                                                                                \033[0m"
echo -e " \033[33;2m                                Referenced from => JamesTurland/JimsGarage                                      \033[0m"

#############################################
# YOU SHOULD ONLY NEED TO EDIT THIS SECTION #
#############################################
# Set the IP addresses of master1
master1=192.168.0.51

# Set the IP addresses of your Longhorn nodes
longhorn1=192.168.0.56
longhorn2=192.168.0.57
longhorn3=192.168.0.58

# User of remote machines
user=ubuntu

# Interface used on remotes
interface=eth0

# Set the virtual IP address (VIP)
vip=192.168.0.50

# Array of longhorn nodes
storage=($longhorn1 $longhorn2 $longhorn3)

# ssh certificate name variable
certName=ubuntu_cloud_ssh_key

#############################################
#            DO NOT EDIT BELOW              #
#############################################
# For testing purposes - in case time is wrong due to VM snapshots
sudo timedatectl set-ntp off
sudo timedatectl set-ntp on

# add ssh keys for all nodes
for node in "${storage[@]}"; do
  ssh-copy-id $user@$node
done

# add open-iscsi - needed for Debian and non-cloud Ubuntu
if ! command -v sudo service open-iscsi status &>/dev/null; then
  echo -e " \033[31;5mOpen-ISCSI not found, installing\033[0m"
  sudo apt install open-iscsi
else
  echo -e " \033[32;5mOpen-ISCSI already installed\033[0m"
fi

# Step 1: Add new longhorn nodes to cluster (note: label added)
for newnode in "${storage[@]}"; do
  k3sup join \
    --ip $newnode \
    --user $user \
    --sudo \
    --k3s-channel stable \
    --server-ip $master1 \
    --k3s-extra-args "--node-label \"longhorn=true\"" \
    --ssh-key $HOME/.ssh/$certName
  echo -e " \033[32;5mAgent node joined successfully!\033[0m"
done

# Step 2: Install Longhorn (using modified Official to pin to Longhorn Nodes)
kubectl apply -f https://raw.githubusercontent.com/Jeswin-8801/HomeLab/refs/heads/main/Kubernetes/Longhorn/longhorn.yml
kubectl get pods \
  --namespace longhorn-system \
  --watch

# Step 3: Install nfs-common for each node
for newnode in "${storage[@]}"; do
  ssh $user@$master1 -i ~/.ssh/$certName <<-EOF
    sudo apt install -y nfs-common
  EOF
done

# Step 4: Print out confirmation

kubectl get nodes
kubectl get svc -n longhorn-system

echo -e " \033[32;5mHappy Kubing! Access Longhorn through Rancher UI\033[0m"
