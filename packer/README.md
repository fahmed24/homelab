# Packer
## [Proxmox Provider](https://developer.hashicorp.com/packer/integrations/hashicorp/proxmox)
## [Ubuntu #autoinstall Reference](https://canonical-subiquity.readthedocs-hosted.com/en/latest/reference/autoinstall-reference.html#autoinstall-configuration-reference-manual)
## [Cloud-Init Reference](https://cloudinit.readthedocs.io/en/latest/reference/examples.html)
## Setting Secrets
- Define secrets within a file ending with `*.pkvars.hcl`
- E.g. `variables.pkvars.hcl`
## Enable Logging
- `export PACKER_LOG=1`
## Packer Build Command
- `packer build -var-file credentials.pkrvars.hcl ubuntu-2204-base.pkr.hcl`
