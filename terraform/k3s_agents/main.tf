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

module "k3s_agent_large_a1" {
  source = "../modules/ubuntu_vm"

  providers = {
    proxmox = proxmox
  }

  target_proxmox_node     = "proxmox1"
  vm_name                 = "K3S-AGENT-LA1"
  cpu_cores               = 4
  memory                  = 8192
  cloud_init_storage_name = "local-zfs"
  primary_storage_size    = "200G"
  primary_storage_name    = "fast"
  vlan_tag                = 100
  ipv4_with_cidr          = "192.168.100.8/24"
  gateway_ipv4            = "192.168.100.1"
}

module "k3s_agent_large_a2" {
  source = "../modules/ubuntu_vm"

  providers = {
    proxmox = proxmox
  }

  target_proxmox_node     = "proxmox1"
  vm_name                 = "K3S-AGENT-LA2"
  cpu_cores               = 4
  memory                  = 8192
  cloud_init_storage_name = "local-zfs"
  primary_storage_size    = "200G"
  primary_storage_name    = "fast"
  vlan_tag                = 100
  ipv4_with_cidr          = "192.168.100.9/24"
  gateway_ipv4            = "192.168.100.1"
}

module "k3s_agent_medium_a3" {
  source = "../modules/ubuntu_vm"

  providers = {
    proxmox = proxmox
  }

  target_proxmox_node     = "proxmox1"
  vm_name                 = "K3S-AGENT-MA3"
  cpu_cores               = 2
  memory                  = 4096
  cloud_init_storage_name = "local-zfs"
  primary_storage_size    = "200G"
  primary_storage_name    = "local-zfs"
  vlan_tag                = 100
  ipv4_with_cidr          = "192.168.100.10/24"
  gateway_ipv4            = "192.168.100.1"
}

module "k3s_agent_medium_a4" {
  source = "../modules/ubuntu_vm"

  providers = {
    proxmox = proxmox
  }

  target_proxmox_node     = "proxmox1"
  vm_name                 = "K3S-AGENT-MA4"
  cpu_cores               = 2
  memory                  = 4096
  cloud_init_storage_name = "local-zfs"
  primary_storage_size    = "200G"
  primary_storage_name    = "local-zfs"
  vlan_tag                = 100
  ipv4_with_cidr          = "192.168.100.11/24"
  gateway_ipv4            = "192.168.100.1"
}

module "k3s_agent_medium_b1" {
  source = "../modules/ubuntu_vm"

  providers = {
    proxmox = proxmox.proxmox2
  }

  target_proxmox_node     = "proxmox2"
  vm_name                 = "K3S-AGENT-MB1"
  cpu_cores               = 2
  memory                  = 4096
  cloud_init_storage_name = "local-lvm"
  primary_storage_size    = "50G"
  primary_storage_name    = "local-lvm"
  vlan_tag                = 100
  ipv4_with_cidr          = "192.168.100.12/24"
  gateway_ipv4            = "192.168.100.1"
}

module "k3s_agent_medium_b2" {
  source = "../modules/ubuntu_vm"

  providers = {
    proxmox = proxmox.proxmox2
  }

  target_proxmox_node     = "proxmox2"
  vm_name                 = "K3S-AGENT-MB2"
  cpu_cores               = 2
  memory                  = 4096
  cloud_init_storage_name = "local-lvm"
  primary_storage_size    = "50G"
  primary_storage_name    = "local-lvm"
  vlan_tag                = 100
  ipv4_with_cidr          = "192.168.100.13/24"
  gateway_ipv4            = "192.168.100.1"
}

module "k3s_agent_medium_c1" {
  source = "../modules/ubuntu_vm"

  providers = {
    proxmox = proxmox.proxmox3
  }

  target_proxmox_node     = "proxmox3"
  vm_name                 = "K3S-AGENT-MC1"
  cpu_cores               = 2
  memory                  = 4096
  cloud_init_storage_name = "local-lvm"
  primary_storage_size    = "50G"
  primary_storage_name    = "fast"
  vlan_tag                = 100
  ipv4_with_cidr          = "192.168.100.14/24"
  gateway_ipv4            = "192.168.100.1"
}
