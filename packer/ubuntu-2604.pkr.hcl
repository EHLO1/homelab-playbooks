source "proxmox-iso" "ubuntu-2604" {
  proxmox_url              = var.proxmox_api_url
  username                 = var.proxmox_api_token_id
  token                    = var.proxmox_api_token_secret
  insecure_skip_tls_verify = true

  node                 = "pve"
  vm_id                = 900
  name                 = "ubuntu-2604-template"
  template_description = "Ubuntu 26.04 Base - UID 1000 & Ansible - Built via Packer"

  iso_file        = "local:iso/ubuntu-26.04-live-server-amd64.iso"
  unmount_iso     = true
  qemu_os         = "l26"
  scsi_controller = "virtio-scsi-pci"

  cores   = 1
  sockets = 1
  memory  = 1024

  network_adapters {
    model  = "virtio"
    bridge = "vmbr0"
  }

  disks {
    disk_size    = "20G"
    format       = "raw"
    storage_pool = "vm1-storage"
    type         = "virtio"
  }

  # ── CHANGED: inline content instead of cd_files ──
  cd_content = {
    "user-data" = templatefile("./cidata/user-data.pkrtpl", {
      ssh_username       = var.ssh_username
      user_password_hash = var.user_password_hash
      personal_ssh_key   = var.personal_ssh_key
      ansible_ssh_key    = var.ansible_ssh_key
    })
    "meta-data" = "instance-id: ubuntu-template\nlocal-hostname: ubuntu-template\n"
  }
  cd_label         = "cidata"
  iso_storage_pool = "local"

  boot_command = [
    "<esc><wait>",
    "e<wait>",
    "<down><down><down><end>",
    " autoinstall",
    "<f10>"
  ]
  boot_wait = "5s"

  ssh_username         = var.ssh_username
  ssh_private_key_file = "~/.ssh/id_rsa"
  ssh_timeout          = "20m"
}