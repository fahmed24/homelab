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

module "k3s_server_a" {
  source = "../modules/ubuntu_vm"

  providers = {
    proxmox = proxmox
  }

  target_proxmox_node     = "proxmox1"
  vm_name                 = "K3S-SERVER-A"
  cpu_cores               = 2
  memory                  = 2048
  cloud_init_storage_name = "local-zfs"
  primary_storage_size    = "40G"
  primary_storage_name    = "local-zfs"
  username                = var.username
  password                = var.password
  pm_ssh_public_keys      = var.pm_ssh_public_keys
  vlan_tag                = 100
  ipv4_with_cidr          = "192.168.100.5/24"
  gateway_ipv4            = "192.168.100.1"
}

module "k3s_server_b" {
  source = "../modules/ubuntu_vm"

  providers = {
    proxmox = proxmox.proxmox2
  }

  target_proxmox_node     = "proxmox2"
  vm_name                 = "K3S-SERVER-B"
  cpu_cores               = 2
  memory                  = 2048
  cloud_init_storage_name = "local-lvm"
  primary_storage_size    = "20G"
  primary_storage_name    = "local-lvm"
  username                = var.username
  password                = var.password
  pm_ssh_public_keys      = var.pm_ssh_public_keys
  vlan_tag                = 100
  ipv4_with_cidr          = "192.168.100.6/24"
  gateway_ipv4            = "192.168.100.1"
}

module "k3s_server_c" {
  source = "../modules/ubuntu_vm"

  providers = {
    proxmox = proxmox.proxmox3
  }

  target_proxmox_node     = "proxmox3"
  vm_name                 = "K3S-SERVER-C"
  cpu_cores               = 2
  memory                  = 2048
  cloud_init_storage_name = "local-lvm"
  primary_storage_size    = "20G"
  primary_storage_name    = "fast"
  username                = var.username
  password                = var.password
  pm_ssh_public_keys      = var.pm_ssh_public_keys
  vlan_tag                = 100
  ipv4_with_cidr          = "192.168.100.7/24"
  gateway_ipv4            = "192.168.100.1"
}

/*
 * PFSEnse restored from PBS on Proxmox3
resource "proxmox_vm_qemu" "pfsense" {
  # Activate QEMU agent for this VM
  # agent = 1
  #os_type = "cloud-init" 
  # Connection to your Proxmox node, note that the VM template should exist on both nodes
  target_node = "proxmox1" # Proxmox node name
  #vmid        = 100                   # Unique VM ID, defaults to 0, using the next available
  name = "PFSENSE" # VM name in Proxmox
  #pool        = "terraform-vms"       # Optional resource pool

  # VM definition
  cpu {
    cores   = 1
    sockets = 1
    type    = "host"
  }

  memory  = 1024
  scsihw  = "virtio-scsi-single"
  # boot    = "order=ide0;scsi0" # Set install disk for initial install
  boot    = "order=virtio0" # Set install disk for initial install
  qemu_os = "other"
  onboot  = true

  disks {
    //
    //For initial Install only
    //ide {
    //  ide0 {
    //    cdrom {
    //      iso = "local:iso/netgate-installer-amd64.iso"
    //    }
    //  }
    //}
    //
    virtio {
      virtio0 {
        disk {
          size       = "10G"
          storage    = "local-zfs"
          iothread   = true
        }
      }
    }
  }

  # Network
  # WAN
  network {
    id     = 0
    model  = "virtio"
    bridge = "vmbr0"
  }

  # LAN
  network {
    id     = 1
    model  = "virtio"
    bridge = "vmbr1"
  }

  # Requuired for console access via Proxmox GUI
  serial {
    id = 0
  }
}
*/



/*
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
*/

/*
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
*/

/*
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

resource "proxmox_lxc" "pihole" {
  target_node  = "proxmox"
  hostname     = "PIHOLE"
  ostemplate   = "local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
  password     = var.pm_root_password
  unprivileged = true

  cores    = 1
  cpulimit = 50  # Uses 50% of 1 Core
  memory   = 512 # In MB
  swap     = 128
  onboot   = true
  start    = true

  ssh_public_keys = <<-EOT
    ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILbcblSecHjRJmXa/KbHzjjtfCDrqxSCZF/h2C3H4hkP ansible@control
  EOT

  // Terraform will crash without rootfs defined
  rootfs {
    storage = "local-lvm"
    size    = "4G" # Use G for Gigabytes
  }

  network {
    name   = "eth0"
    bridge = "vmbr1"
    ip     = "dhcp"
  }
}

variable "k3s_server_nodes" {
  default = {
    server1 = { name = "K3S-SERVER-1", static_ip = "192.168.100.15/24", target_node = "proxmox" }
    server2 = { name = "K3S-SERVER-2", static_ip = "192.168.100.16/24", target_node = "proxmox2" }
    server3 = { name = "K3S-SERVER-3", static_ip = "192.168.100.17/24", target_node = "proxmox2" }
  }
}

resource "proxmox_vm_qemu" "k3s_server_nodes" {

  for_each = var.k3s_server_nodes
  # Activate QEMU agent for this VM
  #agent = 1
  #os_type = "cloud-init" 
  # Connection to your Proxmox node, note that the VM template should exist on both nodes
  target_node = each.value.target_node # Proxmox node name
  #vmid        = 100                   # Unique VM ID, defaults to 0, using the next available
  name = each.value.name # VM name in Proxmox
  #pool        = "terraform-vms"       # Optional resource pool

  # VM definition
  clone      = "ubuntu-2204-cloud-template" # Must exist as a base template
  full_clone = true                         # Usually set to true

  cpu {
    cores   = 2
    sockets = 1
    type    = "host"
  }
  memory  = 4096
  scsihw  = "virtio-scsi-pci"
  boot    = "order=scsi0;net0"
  qemu_os = "l26"
  os_type = "cloud-init"

  disks {
    ide {
      ide2 {
        cloudinit {
          storage = "local-lvm"
        }
      }
    }
    scsi {
      scsi0 {
        disk {
          size       = "20G"
          storage    = "local-lvm"
          iothread   = true
          emulatessd = true
        }
      }
    }
  }

  # Network
  network {
    id     = 0
    model  = "virtio"
    bridge = "vmbr1"
    tag    = 100
  }

  # cloud-init
  ciuser     = "ansible"
  cipassword = "Ultra$VM"
  sshkeys    = <<-EOT
    ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILbcblSecHjRJmXa/KbHzjjtfCDrqxSCZF/h2C3H4hkP ansible@control
  EOT
  ipconfig0  = "ip=${each.value.static_ip},gw=192.168.100.1"
  #ipconfig0 = "ip=dhcp"

  # Requuired for console access via Proxmox GUI
  serial {
    id = 0
  }
}
*/
