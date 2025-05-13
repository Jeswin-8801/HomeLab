#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit
fi

if qm list | grep -w 9000 >/dev/null; then
  echo "VM Template (id 9000) already exists! Pls delete this template or modify the script to create a template with new ID before proceeding"
  exit
fi

# ---------------------------------
USERNAME="USERNAME"
PASSWORD="PASSWORD"
# ---------------------------------

CLOUD_IMG_FILE="/var/lib/vz/template/iso/ubuntu-server-cloudimg-2404.img"
SSH_KEY="/root/.ssh/ubuntu_cloud_ssh_key"

# Username and Password
if [ "$USERNAME" == "USERNAME" ] || [ "$PASSWORD" == "PASSWORD" ]; then
  echo "Please change the USERNAME and PASSWORD variables before executing this script!"
  echo "CAUTION: These credentials will be used by the VMs created from the template generated!"
  exit
fi

# Check for CLOUD_IMG_FILE else Download
if [ ! -f "$CLOUD_IMG_FILE" ]; then
  echo "• Did not find file '${CLOUD_IMG_FILE}'! Downloading..."
  wget "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img" -O "$CLOUD_IMG_FILE"
  if [ $? -eq 0 ]; then
    echo "  - Successfully downloaded cloud img file"
  else
    echo "  - Downloading cloud img file to location '${CLOUD_IMG_FILE}' unsuccessfull"
    exit
  fi
else
  echo "• Cloud image file found => '${CLOUD_IMG_FILE}'"
fi

# Check for SSH_KEY else Generate
if [ ! -f "$SSH_KEY" ]; then
  echo "• No SSH key found at '${SSH_KEY}'. Generating..."
  ssh-keygen -t rsa -C "jeswin.santosh@outlook.com" -N '' -f "$SSH_KEY" <<<y >/dev/null 2>&1
  if [ $? -eq 0 ]; then
    echo "  - Successfully generated SSH key files"
  else
    echo "  - Generating SSH key file '${SSH_KEY}' failed"
    exit
  fi
else
  echo "• SSH key found => '${SSH_KEY}'"
fi

echo "• Modifying cloud-init conf file..."

echo "  - Adding USERNAME '${USERNAME}'"
sed -i 's/USERNAME/'$USERNAME'/g' ubuntu-cloud-init-docker.yaml

echo "  - Adding PASSWORD '${PASSWORD}'"
sed -i 's/PASSWORD/'$PASSWORD'/g' ubuntu-cloud-init-docker.yaml

echo "  - Adding SSH_KEY '${SSH_KEY}.pub'"
sed -i "s/SSH_KEY/$(cat "$SSH_KEY".pub)/g" ubuntu-cloud-init-docker.yaml

# Copy clout-init config file to proxmox snippets path
if [ ! -f "/var/lib/vz/snippets/ubuntu-cloud-init-docker.yaml" ]; then
  if [ ! -d "/var/lib/vz/snippets" ]; then
    echo "• Creating dir '/var/lib/vz/snippets' as it does not exist."
    mkdir -p /var/lib/vz/snippets
  fi
  echo "• Copying config file 'ubuntu-cloud-init-docker.yaml' to '/var/lib/vz/snippets/'"
  cp -f ./ubuntu-cloud-init-docker.yaml /var/lib/vz/snippets/
else
  echo "• Cloud init config file 'ubuntu-cloud-init-docker.yaml' has been found in location '/var/lib/vz/snippets/'"
  echo "  - Replacing if changes are noticed."
  cp -f ./ubuntu-cloud-init-docker.yaml /var/lib/vz/snippets/
fi

echo "• Creating VM Template..."

qm create 9000 --memory 8192 --core 2 --name "ubuntu-cloud-init-docker" --net0 virtio,bridge=vmbr0
qm importdisk 9000 "$CLOUD_IMG_FILE" local-lvm
qm set 9000 --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-9000-disk-0
qm set 9000 --ide2 local-lvm:cloudinit
qm set 9000 --boot c --bootdisk scsi0
qm set 9000 --serial0 socket --vga serial0
qm set 9000 --ipconfig0 ip=dhcp
qm set 9000 --ciuser "$USERNAME" --cipassword $PASSWORD
qm set 9000 --sshkey "$SSH_KEY".pub
qm template 9000

echo ""
if [ $? -eq 0 ]; then
  echo "Template successfully created!"
  echo "You can now run the scipt 'create_vms_for_k3s.sh' to create VMs for a K3s cluster!"
else
  echo ">>>>>> Operation unsuccessfull!"
fi
