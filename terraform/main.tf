# =====================================================================
# main.tf
# Starter Terraform Project for Proxmox
# =====================================================================

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

variable "pm_api_token_id" {
  type = string
}

variable "pm_api_token_secret" {
  type = string
  sensitive = true
}

variable "pm_root_password" {
  type = string
  sensitive = true
}

provider "proxmox" {
  pm_api_url = "https://192.168.68.63:8006/api2/json"
  pm_tls_insecure = true # By default Proxmox Virtual Environment uses self-signed certificates.
  pm_api_token_id = var.pm_api_token_id
  pm_api_token_secret = var.pm_api_token_secret
}

resource "proxmox_lxc" "bastion" {
  target_node  = "proxmox"
  hostname     = "BASTION"
  ostemplate   = "local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
  password     = var.pm_root_password
  unprivileged = true
  
  cores = 1     # Logical cores, e.g. 16 Threads of 8 Physical
  cpulimit = 50 # Uses 50% of 1 Core
  memory = 128
  swap = 128
  onboot = true
  start = true

  ssh_public_keys = <<-EOT
    ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILbcblSecHjRJmXa/KbHzjjtfCDrqxSCZF/h2C3H4hkP ansible@control
  EOT

  // Terraform will crash without rootfs defined
  rootfs {
    storage = "local-lvm"
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

resource "proxmox_lxc" "non_bastion" {
  target_node  = "proxmox"
  hostname     = "NONBASTION"
  ostemplate   = "local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
  password     = var.pm_root_password
  unprivileged = true
  
  cores = 1
  cpulimit = 50 # Uses 50% of 1 Core
  memory = 128
  swap = 128
  onboot = true
  start = true

  ssh_public_keys = <<-EOT
    ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILbcblSecHjRJmXa/KbHzjjtfCDrqxSCZF/h2C3H4hkP ansible@control
  EOT

  // Terraform will crash without rootfs defined
  rootfs {
    storage = "local-lvm"
    size    = "1G" # Size should be greater than 600MB for this template
  }

  network {
    name   = "eth0"
    bridge = "vmbr1"
    ip     = "dhcp"
  }
}

resource "proxmox_lxc" "vlan_test" {
  target_node  = "proxmox"
  hostname     = "VLANTEST"
  ostemplate   = "local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
  password     = var.pm_root_password
  unprivileged = true
  
  cores = 1
  cpulimit = 50 # Uses 50% of 1 Core
  memory = 128
  swap = 128
  onboot = true
  start = true

  ssh_public_keys = <<-EOT
    ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILbcblSecHjRJmXa/KbHzjjtfCDrqxSCZF/h2C3H4hkP ansible@control
  EOT

  // Terraform will crash without rootfs defined
  rootfs {
    storage = "local-lvm"
    size    = "1G" # Size should be greater than 600MB for this template
  }

  network {
    name   = "eth0"
    bridge = "vmbr1"
    ip     = "dhcp"
    tag    = "100" #VLAN Tag
  }
}

resource "proxmox_lxc" "vlan_test_two" {
  target_node  = "proxmox2"
  hostname     = "VLANTESTTWO"
  ostemplate   = "local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
  password     = var.pm_root_password
  unprivileged = true
  
  cores = 1
  cpulimit = 50 # Uses 50% of 1 Core
  memory = 128
  swap = 128
  onboot = true
  start = true

  ssh_public_keys = <<-EOT
    ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILbcblSecHjRJmXa/KbHzjjtfCDrqxSCZF/h2C3H4hkP ansible@control
  EOT

  // Terraform will crash without rootfs defined
  rootfs {
    storage = "local-lvm"
    size    = "1G" # Size should be greater than 600MB for this template
  }

  network {
    name   = "eth0"
    bridge = "vmbr1"
    ip     = "dhcp"
    tag    = "100" #VLAN Tag
  }
}
