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

module "k3s_server_a_test" {
  source = "../../../modules/ubuntu_vm"

  providers = {
    proxmox = proxmox
  }

  target_proxmox_node     = "proxmox1"
  vm_name                 = "K3S-SERVER-A-TEST"
  cpu_cores               = 2
  memory                  = 2048
  cloud_init_storage_name = "local-zfs"
  primary_storage_size    = "40G"
  primary_storage_name    = "local-zfs"
  vlan_tag                = 150
  ipv4_with_cidr          = "192.168.150.5/24"
  gateway_ipv4            = "192.168.150.1"
}

module "k3s_server_b_test" {
  source = "../../../modules/ubuntu_vm"

  providers = {
    proxmox = proxmox.proxmox2
  }

  target_proxmox_node     = "proxmox2"
  vm_name                 = "K3S-SERVER-B-TEST"
  cpu_cores               = 2
  memory                  = 2048
  cloud_init_storage_name = "local-lvm"
  primary_storage_size    = "5G"
  primary_storage_name    = "local-lvm"
  vlan_tag                = 150
  ipv4_with_cidr          = "192.168.150.6/24"
  gateway_ipv4            = "192.168.150.1"
}

module "k3s_server_c_test" {
  source = "../../../modules/ubuntu_vm"

  providers = {
    proxmox = proxmox.proxmox3
  }

  target_proxmox_node     = "proxmox3"
  vm_name                 = "K3S-SERVER-C-TEST"
  cpu_cores               = 2
  memory                  = 2048
  cloud_init_storage_name = "local-lvm"
  primary_storage_size    = "5G"
  primary_storage_name    = "fast"
  vlan_tag                = 150
  ipv4_with_cidr          = "192.168.150.7/24"
  gateway_ipv4            = "192.168.150.1"
}

module "k3s_agent_small_a1_test" {
  source = "../../../modules/ubuntu_vm"

  providers = {
    proxmox = proxmox
  }

  target_proxmox_node     = "proxmox1"
  vm_name                 = "K3S-AGENT-SA1-TEST"
  cpu_cores               = 1
  memory                  = 1024
  cloud_init_storage_name = "local-zfs"
  primary_storage_size    = "5G"
  primary_storage_name    = "fast"
  vlan_tag                = 150
  ipv4_with_cidr          = "192.168.150.14/24"
  gateway_ipv4            = "192.168.150.1"
}
