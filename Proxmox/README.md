# Purpose

Post installation of **Proxmox** from scratch, running:

```bash
cd post-install/
sudo ./install.sh
```

- Creates a new user
- Adds a custom shell environment with all the tools necessary for a minimal dev environment useful when working on the Proxmox instance through SSH when logged in through the new user.

### Virtual Machine Templates

Run the following script to create a template from the `Ubuntu cloud-init` image along with necessary packages like `Docker` installed.

```bash
cd vm-template/
# checkout help for config opts
sudo ./ubuntu_ci_template.sh -h
```

- creates a VM template
- template consists of docker installation configs provided by `ubuntu-cloud-init-docker.yaml` (if opted). This ensures that the VM created from it has Docker installed.

### K3s HA Cluster

The following script creates VMs to be run as an HA cluster on K3s:

```bash
$ sudo ./create_vms_for_k3s.sh -s 192.168.0.51 -g 192.168.0.1 -m 3 -w 2 -i 101
• Creating VM 'k3s-01' '101' with static IP '192.168.0.51'...
  - Cloning successfull!
  - Setting Static IP successfull!
  - VM '101' created successfully!
• Creating VM 'k3s-02' '102' with static IP '192.168.0.52'...
  - Cloning successfull!
  - Setting Static IP successfull!
  - VM '102' created successfully!
• Creating VM 'k3s-03' '103' with static IP '192.168.0.53'...
  - Cloning successfull!
  - Setting Static IP successfull!
  - VM '103' created successfully!
• Creating VM 'k3s-w-01' '104' with static IP '192.168.0.54'...
  - Cloning successfull!
  - Setting worker nodes to have 2 sockets and 2 cores
update VM 104: -cores 2 -sockets 2
  - Setting Static IP successfull!
  - VM '104' created successfully!
• Creating VM 'k3s-w-02' '105' with static IP '192.168.0.55'...
  - Cloning successfull!
  - Setting worker nodes to have 2 sockets and 2 cores
update VM 105: -cores 2 -sockets 2
  - Setting Static IP successfull!
  - VM '105' created successfully!
```

- for more info
```bash
sudo ./create_vms_for_k3s.sh -h
```
