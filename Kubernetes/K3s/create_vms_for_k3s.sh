#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit
fi

usage() {
  echo "Usage: $0 -s <start_ip> -g <gateway> -m <num_master_nodes> -w <num_worker_nodes> -i <vm_id_start> -t <template_id>"
  echo "Options:"
  echo "  -s  Start IP address (e.g., 192.168.1.100)                    (required)"
  echo "      IP of first VM which will sequentially be incremented for each master and worker node corresponding to its VM ID"
  echo "  -g  Gateway IP (e.g., 192.168.1.1)                            (required)"
  echo "  -m  Number of master nodes                                    (required)"
  echo "  -w  Number of worker nodes                                    (required)"
  echo "  -i  VM ID start (first VM ID)                                 (required)"
  echo "  -t  Template VM ID (source VM to clone)                       (optional, 9000 by default)"
  echo "  -h  Show help"
  exit 1
}

# Initialize variables
START_IP=""
GATEWAY=""
NUM_MASTER=""
NUM_WORKER=""
VM_ID_START=""
TEMPLATE_ID=9000

# Parse command-line options
while getopts "s:g:m:w:i:t:h" opt; do
  case $opt in
  s) START_IP="$OPTARG" ;;
  g) GATEWAY="$OPTARG" ;;
  m) NUM_MASTER="$OPTARG" ;;
  w) NUM_WORKER="$OPTARG" ;;
  i) VM_ID_START="$OPTARG" ;;
  t) TEMPLATE_ID="$OPTARG" ;;
  h) usage ;;
  *) usage ;;
  esac
done

# Validate required parameters
if [[ -z "$START_IP" || -z "$GATEWAY" || -z "$NUM_MASTER" || -z "$NUM_WORKER" || -z "$VM_ID_START" ]]; then
  echo "Error: Missing required arguments!"
  usage
fi

if ! qm list | grep -w "$TEMPLATE_ID" >/dev/null; then
  echo "VM Template (id "$TEMPLATE_ID") not found!! Cannot create VMs"
  exit 1
fi

# Copy clout-init config file to proxmox snippets path
PROXMOX_SNIPPETS_LOCATION="/var/lib/vz/snippets"
CONFIG_FILE="ubuntu-cloud-init-docker.yaml"
if [ ! -f "$PROXMOX_SNIPPETS_LOCATION"/"$CONFIG_FILE" ]; then
  echo "ERROR: ${PROXMOX_SNIPPETS_LOCATION}/${CONFIG_FILE} not found"
  exit 1
fi
if ! grep -q "HOSTNAME" "$PROXMOX_SNIPPETS_LOCATION"/"$CONFIG_FILE"; then
  echo "Invalid config file. Did not find string 'HOSTNAME' in '${PROXMOX_SNIPPETS_LOCATION}/${CONFIG_FILE}'"
  exit 1
fi
cp -f "$PROXMOX_SNIPPETS_LOCATION"/"$CONFIG_FILE" .

# Convert IP to numeric for incrementing
IFS='.' read -r IP1 IP2 IP3 IP4 <<<"$START_IP"
CURRENT_IP=$IP4 # Start IP increment from last octet

TOTAL_NODES=$((NUM_MASTER + NUM_WORKER))

for ((i = 0; i < TOTAL_NODES; i++)); do
  VM_ID=$((VM_ID_START + i))

  if qm list | grep -w "$VM_ID" >/dev/null; then
    echo "VM Template (id "$VM_ID") already exists! Cannot create VM."
    exit 1
  fi

  IP="$IP1.$IP2.$IP3.$CURRENT_IP"

  if [ "$i" -lt "$NUM_MASTER" ]; then
    # add 0 if single digit
    formatted_num=$(printf "%02d" $(($i + 1)))
    VM_NAME="k3s-$formatted_num"
  else
    # add 0 if single digit
    formatted_num=$(printf "%02d" $(($i - $NUM_MASTER + 1)))
    VM_NAME="k3s-w-$formatted_num"
  fi

  echo "• Creating VM '$VM_NAME' '$VM_ID' with static IP '$IP'..."

  qm clone "$TEMPLATE_ID" $VM_ID --full true --name "$VM_NAME" --storage local-lvm >/dev/null
  # Enabling minimal console log
  if [ $? -eq 0 ]; then
    echo "  - Cloning successfull!"
  else
    echo "  >>> Cloning unsuccessfull!"
    exit 1
  fi

  # add additional compute to worker nodes
  if [ "$i" -ge "$NUM_MASTER" ]; then
    qm set $VM_ID --sockets 2 --cores 2 >/dev/null
    if [ $? -eq 0 ]; then
      echo "  - Successfully set worker nodes to have 2 sockets and 2 cores"
    else
      echo "  >>> configuring core count unsuccessfull!"
      exit 1
    fi
  fi
  qm set $VM_ID --ipconfig0 "ip=$IP/24,gw=$GATEWAY" >/dev/null
  if [ $? -eq 0 ]; then
    echo "  - Setting Static IP successfull!"
  else
    echo "  >>> IP allotment unsuccessfull!"
    exit 1
  fi

  NEW_CONFIG_FILE="ubuntu-ci-d-${VM_NAME}.yaml"
  cp -f "$CONFIG_FILE" "$NEW_CONFIG_FILE"
  echo "  - Adding HOSTNAME '${VM_NAME}' to '${NEW_CONFIG_FILE}'"
  sed -i "s/HOSTNAME/${VM_NAME}/g" "$NEW_CONFIG_FILE"
  echo "  - Moving file '${NEW_CONFIG_FILE}' to '${PROXMOX_SNIPPETS_LOCATION}'"
  mv "$NEW_CONFIG_FILE" "$PROXMOX_SNIPPETS_LOCATION"

  qm set "$VM_ID" --cicustom "user=local:snippets/${NEW_CONFIG_FILE}" >/dev/null
  if [ $? -eq 0 ]; then
    echo "  - Successfully set cloud-init config file '${PROXMOX_SNIPPETS_LOCATION}/${NEW_CONFIG_FILE}' for VM '${VM_ID}'"
  else
    echo "  >>> Configuring cloud init config file unsuccessfull!"
    exit 1
  fi

  echo "  - VM '$VM_ID' created successfully!"

  ((CURRENT_IP++)) # Increment IP
done

rm -f "$CONFIG_FILE"
