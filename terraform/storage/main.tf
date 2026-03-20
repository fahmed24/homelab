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
  #alias               = "proxmox2"
  pm_api_token_id     = var.pm_api_token_id
  pm_api_url          = var.pm_api_url2
  pm_api_token_secret = var.pm_api_token_secret2
  pm_tls_insecure     = true # By default Proxmox Virtual Environment uses self-signed certificates.
}

resource "proxmox_vm_qemu" "open_media_vault" {
  # Activate QEMU agent for this VM
  # agent = 1
  #os_type = "cloud-init" 
  onboot = true
  # Connection to your Proxmox node, note that the VM template should exist on both nodes
  target_node = "proxmox2" # Proxmox node name
  #vmid        = 100                   # Unique VM ID, defaults to 0, using the next available
  name = "OPEN-MEDIA-VAULT" # VM name in Proxmox
  #pool        = "terraform-vms"       # Optional resource pool

  # VM definition
  cpu {
    cores   = 1
    sockets = 1
    type    = "host"
  }

  memory = 2048
  scsihw = "virtio-scsi-single"
  boot   = "order=ide0" # Set install disk for initial install
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
          iso = "local:iso/openmediavault_8.0.7-amd64.iso"
        }
      }
    }

    scsi {
      //PBS Storage Disk
      scsi0 {
        disk {
          size     = "10G"
          storage  = "local-lvm"
          iothread = true
        }
      }
      /*
       * Proxmox restricts operations to Root
       * 500 Only root can pass arbitrary filesystem paths. at /usr/share/perl5/PVE/Storage.pm line 651
       * Run via shell, after starting this VM
       * qm set 105 -scsi1 /dev/disk/by-id/nvme-NVMe_SSD_256G_IBMC200925600847
      scsi1 {
        passthrough {
          iothread   = true
          backup = false
          file = "/dev/disk/by-id/nvme-NVMe_SSD_256G_IBMC200925600847" 
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
