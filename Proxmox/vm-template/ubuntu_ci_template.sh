#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit
fi

# ---------------------------------
USERNAME=""
PASSWORD=""
CLOUD_IMG_FILE="/var/lib/vz/template/iso/ubuntu-server-cloudimg-2404.img"
SSH_KEY="/root/.ssh/ubuntu_cloud_ssh_key"
TEMPLATE_NAME="ubuntu-ci"
VM_ID=9000
# ---------------------------------

usage() {
  echo "Usage: $0 -u <username> -p <password> -d <enable-docker-install>"
  echo "Options:"
  echo "  -u  string    (required)                              Username"
  echo "  -p  string    (required)                              Password (IMP: Must be given in single Quotes)"
  echo "  -h  Show help"
  exit 1
}

# Check if no arguments were passed
if [[ $# -eq 0 ]]; then
  echo "Error: No arguments provided!"
  usage
fi

while getopts "u:p:dh" opt; do
  case $opt in
  u) USERNAME="$OPTARG" ;;
  p) PASSWORD="$OPTARG" ;;
  h) usage ;;
  *) usage ;;
  esac
done

if qm list | grep -w "$VM_ID" >/dev/null; then
  echo "VM Template (id "$VM_ID") already exists! Pls delete this template or modify the script to create a template with new ID before proceeding"
  exit 1
fi

# Username and Password
if [[ -z "$USERNAME" || -z "$PASSWORD" ]]; then
  echo "Username and Password cannot be empty!"
  echo "CAUTION: These credentials will be used by the VMs created from the template generated!"
  echo ""
  usage
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
# create copy
cp ubuntu-cloud-init-docker.yaml ubuntu-cloud-init-docker.yaml.bak

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
# Revert back
mv ubuntu-cloud-init-docker.yaml.bak ubuntu-cloud-init-docker.yaml

echo "• Creating VM Template..."

qm create "$VM_ID" --memory 8192 --core 2 --name "$TEMPLATE_NAME" --net0 virtio,bridge=vmbr0
qm importdisk "$VM_ID" "$CLOUD_IMG_FILE" local-lvm >/dev/null
# Minimal Logs
if [ $? -eq 0 ]; then
  echo "Successfully imported disk '$CLOUD_IMG_FILE' for VM '$VM_ID'"
fi
qm set "$VM_ID" --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-"$VM_ID"-disk-0
qm resize "$VM_ID" scsi0 25G
qm set "$VM_ID" --ide2 local-lvm:cloudinit
qm set "$VM_ID" --boot c --bootdisk scsi0
qm set "$VM_ID" --serial0 socket --vga serial0
qm set "$VM_ID" --ipconfig0 ip=dhcp
qm set "$VM_ID" --ciuser "$USERNAME" --cipassword "$PASSWORD"
qm set "$VM_ID" --sshkey "$SSH_KEY".pub

qm template "$VM_ID"

echo ""
if [ $? -eq 0 ]; then
  echo ">>>>>> Template successfully created!"
else
  echo ">>>>>> Operation unsuccessfull!"
fi
