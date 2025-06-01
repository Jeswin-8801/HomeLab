# Longhorn

# VMs

> [!Note]
> This is assuming you have a template already created with docker installation using the script (`Proxmox/vm-template/cloud_ci_template.sh`)

The following script creates VMs to be run as an HA cluster on K3s:

```bash
$ sudo ./create_vms_for_longhorn.sh -s 192.168.0.56 -g 192.168.0.1 -n 3 -i 111
```

- for more info
```bash
sudo ./create_vms_for_longhorn.sh -h
```

# Longhorn Setup

> Run the script below after modifying the necessary parameters in the first section of the script:
> ```bash
> sudo ./longhorn-K3S.sh
> ```

- The file `longhorn.yaml` is the manifest file used.
- To access the UI, we create an ingress using the file `longhorn-ingress.yml`. (refer: [longhorn-deploy:ingress](https://longhorn.io/docs/1.9.0/deploy/accessing-the-ui/longhorn-ingress/))
