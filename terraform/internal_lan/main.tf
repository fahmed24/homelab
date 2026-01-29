# =====================================================================
# main.tf
# Starter Terraform Project for Proxmox
# =====================================================================
#
terraform {
  required_version = ">= 1.6.0"

  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.2-rc04"
    }
  }

  backend "local" {
    path = "terraform.tfstate"
  }
}
provider "proxmox" {
  pm_api_token_id     = var.pm_api_token_id
  pm_api_url          = var.pm_api_url
  pm_api_token_secret = var.pm_api_token_secret
  pm_tls_insecure     = true # By default Proxmox Virtual Environment uses self-signed certificates.
}

provider "proxmox" {
  alias               = "proxmox2"
  pm_api_token_id     = var.pm_api_token_id
  pm_api_url          = var.pm_api_url2
  pm_api_token_secret = var.pm_api_token_secret2
  pm_tls_insecure     = true # By default Proxmox Virtual Environment uses self-signed certificates.
}

provider "proxmox" {
  alias               = "proxmox3"
  pm_api_token_id     = var.pm_api_token_id
  pm_api_url          = var.pm_api_url3
  pm_api_token_secret = var.pm_api_token_secret3
  pm_tls_insecure     = true # By default Proxmox Virtual Environment uses self-signed certificates.
}

resource "proxmox_lxc" "bastion" {

  provider = proxmox
  target_node  = "proxmox1"
  hostname     = "BASTION"
  ostemplate   = "local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
  password     = var.pm_root_password
  unprivileged = true

  cores    = 1  # Logical cores, e.g. 16 Threads of 8 Physical
  cpulimit = 25 # Uses 50% of 1 Core
  memory   = 128
  swap     = 128
  onboot   = true
  start    = true


  ssh_public_keys = <<-EOT
    ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILbcblSecHjRJmXa/KbHzjjtfCDrqxSCZF/h2C3H4hkP ansible@control
  EOT

  // Terraform will crash without rootfs defined
  rootfs {
    storage = "local-zfs"
    size    = "1G" # Size should be greater than 600MB for this template
  }

  network {
    name   = "eth0"
    bridge = "vmbr1"
    ip     = "192.168.1.2/24"
    gw     = "192.168.1.1"
  }

  /* DHCP Config on LAN
  network {
    name   = "eth0"
    bridge = "vmbr1"
    ip     = "dhcp"
  }
  */

  /* Static IPv4 Config on LAN
   * Must Set IP w/ CIDR and Gateway
  network {
    name   = "eth0"
    bridge = "vmbr1"
    ip     = "192.168.1.3/24"
    gw     = "192.168.1.1"
  }
  */
}

resource "proxmox_lxc" "ha_proxy_a" {

  provider = proxmox
  target_node  = "proxmox1"
  hostname     = "HAPROXY-A"
  ostemplate   = "local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
  password     = var.pm_root_password
  unprivileged = true

  cores    = 1  # Logical cores, e.g. 16 Threads of 8 Physical
  cpulimit = 25 # Uses 50% of 1 Core
  memory   = 256
  swap     = 256
  onboot   = true
  start    = true

  ssh_public_keys = <<-EOT
    ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILbcblSecHjRJmXa/KbHzjjtfCDrqxSCZF/h2C3H4hkP ansible@control
  EOT

  // Terraform will crash without rootfs defined
  rootfs {
    storage = "local-zfs"
    size    = "2G" # Size should be greater than 600MB for this template
  }

  network {
    name   = "eth0"
    bridge = "vmbr1"
    ip     = "192.168.100.2/24"
    gw     = "192.168.100.1"
    tag    = "100" #VLAN Tag
  }

  /* DHCP Config on LAN
  network {
    name   = "eth0"
    bridge = "vmbr1"
    ip     = "dhcp"
  }
  */

  /* Static IPv4 Config on LAN
   * Must Set IP w/ CIDR and Gateway
  network {
    name   = "eth0"
    bridge = "vmbr1"
    ip     = "192.168.1.3/24"
    gw     = "192.168.1.1"
  }
  */
}

resource "proxmox_lxc" "ha_proxy_b" {
  provider = proxmox.proxmox3

  target_node  = "proxmox3"
  hostname     = "HAPROXY-B"
  ostemplate   = "local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
  password     = var.pm_root_password
  unprivileged = true

  cores    = 1  # Logical cores, e.g. 16 Threads of 8 Physical
  cpulimit = 25 # Uses 50% of 1 Core
  memory   = 256
  swap     = 256
  onboot   = true
  start    = true

  ssh_public_keys = <<-EOT
    ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILbcblSecHjRJmXa/KbHzjjtfCDrqxSCZF/h2C3H4hkP ansible@control
  EOT

  // Terraform will crash without rootfs defined
  rootfs {
    storage = "local-lvm"
    size    = "2G" # Size should be greater than 600MB for this template
  }

  network {
    name   = "eth0"
    bridge = "vmbr1"
    ip     = "192.168.100.3/24"
    gw     = "192.168.100.1"
    tag    = "100" #VLAN Tag
  }

  /* DHCP Config on LAN
  network {
    name   = "eth0"
    bridge = "vmbr1"
    ip     = "dhcp"
  }
  */

  /* Static IPv4 Config on LAN
   * Must Set IP w/ CIDR and Gateway
  network {
    name   = "eth0"
    bridge = "vmbr1"
    ip     = "192.168.1.3/24"
    gw     = "192.168.1.1"
  }
  */
}

