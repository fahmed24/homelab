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

module "postgresql" {
  source = "../modules/ubuntu_vm"

  providers = {
    proxmox = proxmox
  }

  target_proxmox_node     = "proxmox1"
  vm_name                 = "POSTGRESQL"
  cpu_cores               = 2
  memory                  = 4096
  cloud_init_storage_name = "fast"
  primary_storage_size    = "200G"
  primary_storage_name    = "fast"
  vlan_tag                = 200
  ipv4_with_cidr          = "192.168.200.2/24"
  gateway_ipv4            = "192.168.200.1"
}
