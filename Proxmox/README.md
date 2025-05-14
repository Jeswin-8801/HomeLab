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
