# K3s HA Cluster

# VMs

> [!Note]
> This is assuming you have a template already created with docker installation using the script (`Proxmox/vm-template/cloud_ci_template.sh`)

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

# K3s Nodes Spin Up

> Run the script below after modifying the necessary parameters in the first section of the script:
> ```bash
> sudo ./k3s.sh
> ```
