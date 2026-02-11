packer {
  required_plugins {
    proxmox = {
      version = ">= 1.2.3"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

variable "proxmox_iso_pool" {
  type    = string
  default = "local:iso"
}

variable "proxmox_node" {
  type    = string
  default = "proxmox2"
}

variable "proxmox_storage_format" {
  type    = string
  default = "raw"
}

variable "proxmox_storage_pool" {
  type    = string
  default = "local-lvm"
}

variable "proxmox_url" {
  type    = string
  default = env("TF_VAR_pm_api_url2")
}

variable "template_description" {
  type    = string
  default = "Ubuntu 22.04 Template"
}

variable "template_name" {
  type    = string
  default = "Ubuntu-22.04-Template-Standard-ISO"
}

variable "ubuntu_image" {
  type    = string
  default = "ubuntu-22.04.5-live-server-amd64.iso"
}

variable "version" {
  type    = string
  default = ""
}

variable "pm_api_token_id" {
  type = string
  sensitive = true
  default = env("TF_VAR_pm_api_token_id")
}

variable "pm_api_token_secret" {
  type      = string
  sensitive = true
  default   = env("TF_VAR_pm_api_token_secret2")
}

# Make sure to use this with an ISO file
source "proxmox-iso" "ubuntu_2204" {
  username = "${var.pm_api_token_id}"
  token    = "${var.pm_api_token_secret}"

  bios     = "ovmf"
  machine  = "q35"
  boot_command = ["c", "linux /casper/vmlinuz -- autoinstall ds='nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/'", "<enter><wait><wait>", "initrd /casper/initrd", "<enter><wait><wait>", "boot<enter>"]
  boot_wait    = "10s"
  cores        = "2"

  disks {
    disk_size    = "8G"
    format       = "${var.proxmox_storage_format}"
    storage_pool = "${var.proxmox_storage_pool}"
    type         = "scsi"
  }

  efi_config {
    efi_storage_pool  = "${var.proxmox_storage_pool}"
    #2m (No Secure Boot) vs 4m (Secure Boot) 
    efi_type          = "2m"
    pre_enrolled_keys = true
  }

  http_directory           = "./http"
  insecure_skip_tls_verify = true
  iso_file                 = "${var.proxmox_iso_pool}/${var.ubuntu_image}"
  memory                   = "2048"

  network_adapters {
    bridge   = "vmbr1"
    vlan_tag = "100" # Doesn't need to be on VLAN
  }

  node            = "${var.proxmox_node}"
  os              = "l26"
  proxmox_url     = "${var.proxmox_url}"
  scsi_controller = "virtio-scsi-single"

  ssh_username         = "ubuntu"
  ssh_password         = "ubuntu"
  ssh_port             = 22
  ssh_timeout          = "30m"
  ssh_private_key_file = "~/.ssh/ansible"

  ssh_bastion_host             = "192.168.1.2"
  ssh_bastion_username         = "ansible"
  ssh_bastion_private_key_file = "~/.ssh/ansible"
  ssh_disable_agent_forwarding = true

  template_description = "${var.template_description}"
  template_name        = "${var.template_name}"
  unmount_iso          = true
  cloud_init = true
  cloud_init_storage_pool = var.proxmox_storage_pool
}

build {
  sources = ["source.proxmox-iso.ubuntu_2204"]

  provisioner "shell" {
    inline = ["while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done", "sudo rm -f /etc/cloud/cloud.cfg.d/99-installer.cfg", "sudo cloud-init clean", "sudo passwd -d ubuntu"]
  }

}
