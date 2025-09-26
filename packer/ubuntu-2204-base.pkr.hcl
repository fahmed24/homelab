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
  default = "proxmox"
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
  default = "https://192.168.68.63:8006/api2/json"
}

variable "template_description" {
  type    = string
  default = "Ubuntu 22.04 Template"
}

variable "template_name" {
  type    = string
  default = "Ubuntu-22.04-Template"
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
}

variable "pm_api_token_secret" {
  type      = string
  sensitive = true
}

source "proxmox-iso" "ubuntu_2204" {
  username = "${var.pm_api_token_id}"
  token    = "${var.pm_api_token_secret}"

  boot_command = ["c", "linux /casper/vmlinuz -- autoinstall ds='nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/'", "<enter><wait><wait>", "initrd /casper/initrd", "<enter><wait><wait>", "boot<enter>"]
  boot_wait    = "10s"
  cores        = "2"

  disks {
    disk_size    = "8G"
    format       = "${var.proxmox_storage_format}"
    storage_pool = "${var.proxmox_storage_pool}"
    type         = "scsi"
  }

  http_directory           = "./http"
  insecure_skip_tls_verify = true
  iso_file                 = "${var.proxmox_iso_pool}/${var.ubuntu_image}"
  memory                   = "2048"

  network_adapters {
    bridge   = "vmbr1"
    vlan_tag = "100"
  }

  node            = "${var.proxmox_node}"
  os              = "l26"
  proxmox_url     = "${var.proxmox_url}"
  scsi_controller = "virtio-scsi-single"

  ssh_username         = "ubuntu"
  ssh_password         = "ubuntu"
  ssh_port             = 22
  ssh_timeout          = "30m"
  ssh_private_key_file = "~/.ssh/ansible_proxmox"

  ssh_bastion_host             = "192.168.1.2"
  ssh_bastion_username         = "ansible"
  ssh_bastion_private_key_file = "~/.ssh/ansible_proxmox"
  ssh_disable_agent_forwarding = true

  template_description = "${var.template_description}"
  template_name        = "${var.template_name}"
  unmount_iso          = true
}

build {
  sources = ["source.proxmox-iso.ubuntu_2204"]

  provisioner "shell" {
    inline = ["while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done", "sudo rm -f /etc/cloud/cloud.cfg.d/99-installer.cfg", "sudo cloud-init clean", "sudo passwd -d ubuntu"]
  }

}
