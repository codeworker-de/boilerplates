resource "proxmox_vm_qemu" "srv_demo_1" {

  # VM Settings: Metadaten
  name        = "srv-demo-tf-1"
  desc        = "[Ubuntu] Erstellt mit Terraform"
  vmid        = "401"
  target_node = "pve"
  clone       = "ubuntu-server-jammy" # Name des VM templates! NICHT DIE ID!!!
  
  # VM Settings: Ist der QEMU Agent auf der VM vorhanden? 1 = Ja; 0 = Nein
  agent = 1

  # Hardware Settings: CPU
  cores   = 4
  sockets = 1
  cpu     = "host"

  # Hardware Settings: RAM
  memory  = 8192

  cloudinit_cdrom_storage = "local-lvm" # Sonst wird kein Cloud-Init Image erstellt
  
  # Hardware Settings: Netzwerk
  network {
    bridge = "vmbr0"
    model  = "virtio"
  }

  # Hardware Settings: Festplatte
  # Sie muss identisch zur Festplatte aus dem Proxmox Template sein. 
  # Andernfalls legt Terraform eine 2. Festplatte mit der Konfiguration an.
  disks {
    virtio {
      virtio0 {
        disk {
          size    = 20
          storage = "local-lvm"
        }
      }
    }
  }

  os_type = "cloud-init"

  # Optional: Network settings (Wird dann per Cloud-init gesetzt)
  #ipconfig0  = "ip=10.0.13.240/24,gw=10.0.13.1"
  #nameserver = "10.0.13.1"

  # Optional: User settings (Wird dann per Cloud-init gesetzt)
  #ciuser     = "<BENUTZERNAME>"
  #sshkeys = <<EOF
  # PUBLIC SSH_KEY EINFUEGEN
  #EOF

}
