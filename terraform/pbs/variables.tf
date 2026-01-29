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

variable "pm_root_password" {
  type      = string
  sensitive = true
}
