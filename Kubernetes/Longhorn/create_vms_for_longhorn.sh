#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit
fi

usage() {
  echo "Usage: $0 -s <start_ip> -g <gateway> -n <num_nodes> -i <vm_id_start> -t <template_id>"
  echo "Options:"
  echo "  -s  Start IP address (e.g., 192.168.1.100)                    (required)"
  echo "      IP of first VM which will sequentially be incremented for each master and worker node corresponding to its VM ID"
  echo "  -g  Gateway IP (e.g., 192.168.1.1)                            (required)"
  echo "  -n  Number of nodes                                           (required)"
  echo "  -i  VM ID start (first VM ID)                                 (required)"
  echo "  -t  Template VM ID (source VM to clone)                       (optional, 9000 by default)"
  echo "  -h  Show help"
  exit 1
}

# Initialize variables
START_IP=""
GATEWAY=""
NODE_COUNT=""
VM_ID_START=""
TEMPLATE_ID=9000

# Parse command-line options
while getopts "s:g:n:i:t:h" opt; do
  case $opt in
  s) START_IP="$OPTARG" ;;
  g) GATEWAY="$OPTARG" ;;
  n) NODE_COUNT="$OPTARG" ;;
  i) VM_ID_START="$OPTARG" ;;
  t) TEMPLATE_ID="$OPTARG" ;;
  h) usage ;;
  *) usage ;;
  esac
done

# Validate required parameters
if [[ -z "$START_IP" || -z "$GATEWAY" || -z "$NODE_COUNT" || -z "$VM_ID_START" || -z "$TEMPLATE_ID" ]]; then
  echo "Error: Missing required arguments!"
  usage
fi

if ! qm list | grep -w "$TEMPLATE_ID" >/dev/null; then
  echo "VM Template (id "$TEMPLATE_ID") not found!! Cannot create VMs"
  exit 1
fi

# Convert IP to numeric for incrementing
IFS='.' read -r IP1 IP2 IP3 IP4 <<<"$START_IP"
CURRENT_IP=$IP4 # Start IP increment from last octet

for ((i = 0; i < NODE_COUNT; i++)); do
  VM_ID=$((VM_ID_START + i))

  if qm list | grep -w "$VM_ID" >/dev/null; then
    echo "VM Template (id "$VM_ID") already exists! Cannot create VM."
    exit 1
  fi

  IP="$IP1.$IP2.$IP3.$CURRENT_IP"

  # add 0 if single digit
  formatted_num=$(printf "%02d" "$(("$i" + 1))")
  VM_NAME="longhorn-$formatted_num"

  echo "• Creating VM '$VM_NAME' '$VM_ID' with static IP '$IP'..."

  qm clone "$TEMPLATE_ID" $VM_ID --full true --name "$VM_NAME" --storage local-lvm >/dev/null
  # Enabling minimal console log
  if [ $? -eq 0 ]; then
    echo "  - Cloning successfull!"
  else
    echo "  >>> Cloning unsuccessfull!"
    exit 1
  fi

  qm set $VM_ID --ipconfig0 "ip=$IP/24,gw=$GATEWAY" >/dev/null
  if [ $? -eq 0 ]; then
    echo "  - Setting Static IP successfull!"
  else
    echo "  >>> IP allotment unsuccessfull!"
    exit 1
  fi

  echo "  - VM '$VM_ID' created successfully!"

  ((CURRENT_IP++)) # Increment IP
done
