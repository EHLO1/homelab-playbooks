source "proxmox-iso" "ubuntu-2604-docker" {
  proxmox_url              = var.proxmox_api_url
  username                 = var.proxmox_api_token_id
  token                    = var.proxmox_api_token_secret
  insecure_skip_tls_verify = true

  node                 = var.node
  vm_id                = 8100
  name                 = "ubuntu-2604-docker"
  template_description = "Ubuntu 26.04 Docker Host Template - Built via Packer"

  iso_file        = "local:iso/ubuntu-26.04-live-server-amd64.iso"
  unmount_iso     = true
  qemu_os         = "l26"
  scsi_controller = "virtio-scsi-pci"

  cores   = 1
  sockets = 1
  memory  = 1024

  qemu_agent = true

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

  cd_content = {
    "user-data" = templatefile("./cidata/user-data.pkrtpl", {
      username           = var.username
      user_password_hash = var.user_password_hash
      personal_ssh_key   = var.personal_ssh_key
      ansible_ssh_key    = var.ansible_ssh_key
    })
    "meta-data" = "instance-id: linux-template\nlocal-hostname: linux-template\n"
  }
  cd_label         = "cidata"
  iso_storage_pool = "local"

  boot_command = [
    "<esc><wait>",
    "e<wait>",
    "<down><down><down><end>",
    " autoinstall ds=nocloud;s=/cdrom/",
    "<f10>"
  ]
  boot_wait = "5s"

  ssh_username         = "ansible"
  ssh_private_key      = var.ansible_ssh_private_key_string
  ssh_timeout          = "20m"
}

build {
  sources = ["source.proxmox-iso.ubuntu-2604-docker"]

  # Install Docker
  provisioner "shell" {
    inline = [
      "echo 'Waiting for cloud-init to finish...'",
      "cloud-init status --wait",
      
      "echo 'Installing Docker...'",
      "sudo apt-get update",
      "sudo apt-get install -y ca-certificates curl",
      "sudo install -m 0755 -d /etc/apt/keyrings",
      "sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc",
      "sudo chmod a+r /etc/apt/keyrings/docker.asc",
      "echo \"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",
      "sudo apt-get update",
      "sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin",
      
      "echo 'Adding users to Docker group...'",
      "sudo usermod -aG docker ${var.username}",
    ]
  }

  # Template Cleanup: Ensures cloned VMs get unique IPs and MACs
  provisioner "shell" {
    inline = [
      "echo 'Cleaning up machine-id and cloud-init...'",
      "sudo truncate -s 0 /etc/machine-id",
      "sudo rm -f /var/lib/dbus/machine-id",
      "sudo ln -s /etc/machine-id /var/lib/dbus/machine-id",
      "sudo cloud-init clean",
      "sudo rm -f /etc/ssh/ssh_host_*",
      "sudo apt-get autoremove -y",
      "sudo apt-get clean"
    ]
  }
}