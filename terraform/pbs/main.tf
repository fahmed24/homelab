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

provider "proxmox" {
  pm_api_url          = var.pm_api_url
  pm_tls_insecure     = true # By default Proxmox Virtual Environment uses self-signed certificates.
  pm_api_token_id     = var.pm_api_token_id
  pm_api_token_secret = var.pm_api_token_secret
}

resource "proxmox_vm_qemu" "pbs_backup_server" {
  # Activate QEMU agent for this VM
  # agent = 1
  #os_type = "cloud-init" 
  onboot = true
  # Connection to your Proxmox node, note that the VM template should exist on both nodes
  target_node = "proxmox2" # Proxmox node name
  #vmid        = 100                   # Unique VM ID, defaults to 0, using the next available
  name = "PBS-BACKUP" # VM name in Proxmox
  #pool        = "terraform-vms"       # Optional resource pool

  # VM definition
  cpu {
    cores   = 2
    sockets = 1
    type    = "host"
  }

  memory  = 8192
  scsihw  = "virtio-scsi-single"
  boot    = "order=ide0" # Set install disk for initial install
  # boot    = "order=scsi0" # Set install disk for initial install
  qemu_os = "l26"

  disks {
    /*
     * For initial Install only
    ide {
      ide0 {
        cdrom {
          iso = "local:iso/netgate-installer-amd64.iso"
        }
      }
    }
    */
    ide {
      ide0 {
        cdrom {
          iso = "local:iso/proxmox-backup-server_4.0-1.iso"
        }
      }
    }
    
    scsi {
      //PBS Storage Disk
      scsi0 {
        disk {
          size       = "32G"
          storage    = "fast"
          iothread   = true
        }
      }
      /*
       * Proxmox restricts operations to Root
       * 500 Only root can pass arbitrary filesystem paths. at /usr/share/perl5/PVE/Storage.pm line 651
       * Run via shell, after starting this VM
       * qm set 100 -scsi1 /dev/disk/by-id/ata-ST2000DM008-2UB102_ZFL8PQ59
       * qm set 100 -scsi2 /dev/disk/by-id/ata-ST2000DX002-2DV164_Z4Z8HYH1
      scsi1 {
        passthrough {
          iothread   = true
          backup = false
          file = "/dev/disk/by-id/ata-ST2000DM008-2UB102_ZFL8PQ59" 
        }
      }
      scsi2 {
        passthrough {
          iothread   = true
          backup = false
          file = "/dev/disk/by-id/ata-ST2000DX002-2DV164_Z4Z8HYH1" 
        }
      }
      */
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
  /*
   * Don't need LAN communication on this for now
  network {
    id     = 1
    model  = "virtio"
    bridge = "vmbr1"
  }
  */

  # Requuired for console access via Proxmox GUI
  serial {
    id = 0
  }
}
