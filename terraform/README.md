# Terraform
## [Proxmox Provider](https://registry.terraform.io/providers/Telmate/proxmox/latest/docs/resources/lxc)
## Setting Secrets
- Define secrets within a file ending with `*.auto.tfvars`
- E.g. `credentials.auto.tfvars`

## Quick Command Ref
- Target Destroy
terraform destroy -target proxmox_vm_qemu.k3s_server_nodes

- Import Resources into State
- See Provider for IDs
terraform import module.node1.proxmox_vm_qemu.pfsense proxmox1/qemu/100
