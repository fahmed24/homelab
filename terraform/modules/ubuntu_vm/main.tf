# Must exist with this resource and the parent definition in ../../k3s_agents/main.tf
terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.2-rc04"
    }
  }
}

resource "proxmox_vm_qemu" "ubuntu_vm" {

  # Activate QEMU agent for this VM
  agent = 1
  #os_type = "cloud-init" 
  # Connection to your Proxmox node, note that the VM template should exist on both nodes
  target_node = var.target_proxmox_node # Proxmox node name
  #vmid        = 100                   # Unique VM ID, defaults to 0, using the next available
  name = var.vm_name # VM name in Proxmox
  #pool        = "terraform-vms"       # Optional resource pool

  # VM definition
  clone      = var.clone_template_name # Must exist as a base template
  full_clone = true                    # Usually set to true
  onboot     = true
  bios       = var.bios
  vm_state   = var.vm_state

  cpu {
    cores   = var.cpu_cores
    sockets = 1
    type    = "host"
  }
  memory  = var.memory
  scsihw  = "virtio-scsi-single"
  boot    = "order=scsi0;net0"
  qemu_os = "l26"
  os_type = "cloud-init"

  disks {
    ide {
      ide2 {
        cloudinit {
          storage = var.cloud_init_storage_name
        }
      }
    }
    scsi {
      scsi0 {
        disk {
          size       = var.primary_storage_size
          storage    = var.primary_storage_name
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
    tag    = var.vlan_tag
  }

  # cloud-init
  #ciuser     = "default"
  #cipassword = "Ultra$VM"
  ciuser     = var.username
  cipassword = var.password

  sshkeys   = var.pm_ssh_public_keys
  ipconfig0 = "ip=${var.ipv4_with_cidr},gw=${var.gateway_ipv4}"
  #ipconfig0 = "ip=dhcp"

  # Required for console access via Proxmox GUI
  /*
  serial {
    id = 0
  }
  */
}
