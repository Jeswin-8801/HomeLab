# Purpose

Post installation of **Proxmox** from scratch, running:

```bash
cd post-install/
./install.sh
```

- Creates a new user
- Adds a custom shell environment with all the tools necessary for a minimal dev environment useful when working on the Proxmox instance through SSH when logged in through the new user.

### VM Templates

Run the following script to create a template from the `Ubuntu cloud-init` image along with necessary packages like `Docker` installed.

```bash
cd vm-template/
./create_vm_template.sh
```

- creates a VM template
- template consists of docker installation configs provided by `ubuntu-cloud-init-docker.yaml`. This ensures that the VM created from it has Docker installed.
