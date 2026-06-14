variable "ssh_username" {
  type    = string
  default = "yourusername"
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