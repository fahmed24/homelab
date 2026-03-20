variable "pm_api_token_id" {
  type = string
}

variable "pm_api_token_secret" {
  type      = string
  sensitive = true
}

variable "pm_api_url" {
  type      = string
  sensitive = true
}

variable "pm_api_url2" {
  type      = string
  sensitive = true
}

variable "pm_api_token_secret2" {
  type      = string
  sensitive = true
}

variable "pm_api_url3" {
  type      = string
  sensitive = true
}

variable "pm_api_token_secret3" {
  type      = string
  sensitive = true
}

variable "username" {
  type      = string
  sensitive = true
}

variable "password" {
  type      = string
  sensitive = true
}

variable "pm_ssh_public_keys" {
  type      = string
  sensitive = true
}
