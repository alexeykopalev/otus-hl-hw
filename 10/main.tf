provider "proxmox" {
  pm_api_url = var.api_url
  
  pm_api_token_id = var.token_id
  
  pm_api_token_secret = var.token_secret
  
  pm_tls_insecure = true

}

resource "proxmox_vm_qemu" "bast_host" {
  count = 1
  name = "bast-host"
  target_node = var.proxmox_host
  clone = var.template_name
  agent = 1
  os_type = "cloud-init"
  cores = 2
  sockets = 1
  vcpus = 0
  cpu = "host"
  memory = 2048
  scsihw = "virtio-scsi-single"
  bootdisk = "scsi0"
  disk {
        slot = 0
        size = "10G"
        type = "scsi"
        storage = "ssd_1tb"
        ssd = 1
    }
  
  network {
    model = "virtio"
    bridge = "vmbr0"
    firewall  = false
    link_down = false
  }
  ipconfig0 = "ip=10.6.6.11/24,gw=10.6.6.1"
  
  ciuser = var.vm_user
  ssh_user = var.vm_user
  sshkeys = <<EOF
  ${var.ssh_key}
  EOF
}

resource "proxmox_vm_qemu" "backend_hosts" {
  count = 1
  name = "backend-srv"
  target_node = var.proxmox_host
  clone = var.template_name
  agent = 1
  os_type = "cloud-init"
  cores = 2
  sockets = 1
  vcpus = 0
  cpu = "host"
  memory = 2048
  scsihw = "virtio-scsi-single"
  bootdisk = "scsi0"
  disk {
        slot = 0
        size = "10G"
        type = "scsi"
        storage = "ssd_1tb"
        ssd = 1
    }
  
  network {
    model = "virtio"
    bridge = "vmbr1"
    firewall  = false
    link_down = false
  }
  ipconfig0 = "ip=10.6.7.50/24,gw=10.6.7.1"
  
  ciuser = var.vm_user
  ssh_user = var.vm_user
  sshkeys = <<EOF
  ${var.ssh_key}
  EOF
}

resource "proxmox_vm_qemu" "db_hosts" {
  count = 1
  name = "db-srv"
  target_node = var.proxmox_host
  clone = var.template_name
  agent = 1
  os_type = "cloud-init"
  cores = 2
  sockets = 1
  vcpus = 0
  cpu = "host"
  memory = 2048
  scsihw = "virtio-scsi-single"
  bootdisk = "scsi0"
  disk {
        slot = 0
        size = "10G"
        type = "scsi"
        storage = "ssd_1tb"
        ssd = 1
    }
  
  network {
    model = "virtio"
    bridge = "vmbr1"
    firewall  = false
    link_down = false
  }
  ipconfig0 = "ip=10.6.7.6/24,gw=10.6.7.1"
  
  ciuser = var.vm_user
  ssh_user = var.vm_user
  sshkeys = <<EOF
  ${var.ssh_key}
  EOF
}

resource "local_file" "inventory_file" {
  content = templatefile("${path.module}/templates/inventory.tpl",
    {
      bast_host    = proxmox_vm_qemu.bast_host[*]
      backend_hosts    = proxmox_vm_qemu.backend_hosts[*]
      db_hosts    = proxmox_vm_qemu.db_hosts[*]
    }
  )
  filename = "${path.module}/ansible/inventory.txt"
}