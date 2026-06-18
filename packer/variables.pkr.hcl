variable "proxmox_api_url" {
  type      = string
  sensitive = true
}

variable "proxmox_api_token_id" {
  type      = string
  sensitive = true
}

variable "proxmox_api_token_secret" {
  type      = string
  sensitive = true
}

variable "node" {
  type = string
  default = "lnet-serv1"
}


variable "username" {
  type    = string
  sensitive = true
}

variable "user_password_hash" {
  type      = string
  sensitive = true
  # Generate with: mkpasswd --method=SHA-512
  # (mkpasswd is in the 'whois' package on Debian/Ubuntu)
}

variable "personal_ssh_key" {
  type = string
}

variable "ansible_ssh_key" {
  type = string
}