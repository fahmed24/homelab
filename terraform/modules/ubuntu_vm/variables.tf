# variables.tf
variable "target_proxmox_node" {
  description = "Proxmox node name where VM will be created"
  type        = string
}

variable "vm_name" {
  description = "Name of the VM in Proxmox"
  type        = string
}

variable "clone_template_name" {
  description = "Name of the template to clone from"
  type        = string
  default     = "UBUNTU-2204-CLOUD-TEMPLATE"
}

variable "cpu_cores" {
  description = "Number of CPU cores"
  type        = number
}

variable "memory" {
  description = "Memory in MB"
  type        = number
}

variable "cloud_init_storage_name" {
  description = "Storage name for cloud-init drive"
  type        = string
}

variable "primary_storage_size" {
  description = "Primary disk size (e.g., '20G')"
  type        = string
}

variable "primary_storage_name" {
  description = "Storage name for primary disk"
  type        = string
}

variable "vlan_tag" {
  description = "VLAN tag for network interface"
  type        = number
}

variable "ipv4_with_cidr" {
  description = "IPv4 address with CIDR notation (e.g., '192.168.1.10/24')"
  type        = string
}

variable "gateway_ipv4" {
  description = "Gateway IPv4 address"
  type        = string
}
