#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit
fi

if ! qm list | grep -w 9000 >/dev/null; then
  echo "VM Template (id 9000) does not exist! Pls create the template (using create_vm_template.sh) before moving onto this step."
  exit
fi

for ID in {111..115}; do
  echo "Creating VM $ID..."
  # Clone from VM 9000
  qm clone 9000 $ID --full true --name "k3s-test-$ID" --storage local-lvm
  # Apply Cloud-Init settings
  qm set $ID --cicustom "user=local:snippets/ubuntu-cloud-init-docker.yaml"
  echo "VM $ID created successfully!"
done
