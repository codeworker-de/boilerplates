packer {
   required_plugins {
    virtualbox = {
      version = ">= 1.0.5"
      source = "github.com/hashicorp/virtualbox"
    }
    vagrant = {
      version = ">= 1.1.2"
      source = "github.com/hashicorp/vagrant"
    }
    proxmox = {
      version = "~> 1"
      source  = "github.com/hashicorp/proxmox"
    }
    ansible = {
      version = ">= 1.1.1"
      source = "github.com/hashicorp/ansible"
    }
  }
} 

# Als Alternative zu Variablen koennen auch Umgebungsvariablen genutzt werden.
# Sie muessen dann folgendes Schema aufweisen:
# PKR_VAR_name
# Beispiel: PKR_VAR_proxmox_api_url=http://abc.local:8006/api2/json

# Variable Definitions
variable "ssh_username" {
    type = string
}

variable "ssh_password" {
    type = string
    sensitive = true # true --> wird in der Ausgabe nicht angezeigt
} 

variable "proxmox_api_url" {
    type = string
}

variable "proxmox_api_token_id" {
    type = string
}

variable "proxmox_api_token_secret" {
    type = string
    sensitive = true # true --> wird in der Ausgabe nicht angezeigt
}

source "virtualbox-iso" "ubuntu-server" {
  guest_os_type = "Ubuntu22_LTS_64"

  iso_url = "http://releases.ubuntu.com/22.04.2/ubuntu-22.04.2-live-server-amd64.iso"
  iso_checksum = "SHA256:5e38b55d57d94ff029719342357325ed3bda38fa80054f9330dc789cd2d43931"

  memory = 2048
 
  http_directory = "http"

  boot_command = [
    "<esc>",
    "e",
    "<down><down><down><end>",
    "<bs><bs><bs><bs>",
    "autoinstall ds=nocloud-net\\;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ ---<wait5>",
    "<f10>"
  ]

  vboxmanage   = [["modifyvm", "{{.Name}}", "--nat-localhostreachable1", "on"]]

  ssh_timeout = "1h30m"
  ssh_username = "${var.ssh_username}"
  ssh_password = "${var.ssh_password}"
  shutdown_command = "echo 'packer' | sudo -S shutdown -P now"
}

source "proxmox-iso" "ubuntu-server" {
    # Proxmox Connection Settings
    proxmox_url = "${var.proxmox_api_url}"
    username = "${var.proxmox_api_token_id}"
    token = "${var.proxmox_api_token_secret}"
    
    # (Optional) Skip TLS Verification
    insecure_skip_tls_verify = true
    
    # VM General Settings
    node = "pve"
    vm_id = "500"
    vm_name = "ubuntu-server-jammy-docker"
    template_description = "Ubuntu Server jammy Image includes docker"

    # VM OS Settings
    # (Option 1) Local ISO File
    #iso_file = "local:iso/ubuntu-22.04.4-live-server-amd64.iso"
    # - or -
    # (Option 2) Download ISO
    # Wenn iso_url genutzt wird, dann muss auch iso_checksum gesetzt sein!
    #iso_url = "https://releases.ubuntu.com/22.04/ubuntu-22.04.4-live-server-amd64.iso"
    #iso_checksum = "45f873de9f8cb637345d6e66a583762730bbea30277ef7b32c9c3bd6700a32b2"
    iso_storage_pool = "local"
    unmount_iso = true

    # VM System Settings
    qemu_agent = true

    # VM Hard Disk Settings
    scsi_controller = "virtio-scsi-pci"

    # VM HDD Settings
    disks {
        disk_size = "20G"
        storage_pool = "local-lvm"
        storage_pool_type = "lvm"
        type = "virtio"
    }

    # VM CPU Settings
    cores = "2"
    
    # VM Memory Settings
    memory = "4096" 

    # VM Network Settings
    network_adapters {
        model = "virtio"
        bridge = "vmbr0"
        firewall = "false"
    } 

    # VM Cloud-Init Settings
    cloud_init = true
    cloud_init_storage_pool = "local-lvm"

    http_directory = "http"

    boot_command = [
      "<esc>",
      "e",
      "<down><down><down><end>",
      "<bs><bs><bs><bs>",
      "autoinstall ds=nocloud-net\\;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ ---<wait5>",
      "<f10>"
    ]

    # SSH Timeout und Connection settings fuer packer
    ssh_timeout = "30m"
    ssh_username = "${var.ssh_username}"
    ssh_password = "${var.ssh_password}"
}

build {
    name = "vagrant"
    sources = ["sources.virtualbox-iso.ubuntu-server"] 

    post-processors {

     post-processor "vagrant" {
        keep_input_artifact = true
        output = "ubuntu-server-22-04.box"
        provider_override = "virtualbox"
     } 

    } 
} 

build {
  name = "proxmox"

  sources= ["sources.proxmox-iso.ubuntu-server"]

  # Provisioning the docker-playbook by using ansible 
  provisioner "ansible" {
    playbook_file = "./ansible/docker-playbook.yml"
    groups = ["docker"]
    #extra_arguments = [ "-vvvv" ]
  }

  # Provisioning the VM Template for Cloud-Init Integration in Proxmox #1
  provisioner "shell" {
      inline = [
          "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done",
          "sudo rm /etc/ssh/ssh_host_*",
          "sudo truncate -s 0 /etc/machine-id",
          "sudo apt -y autoremove --purge",
          "sudo apt -y clean",
          "sudo apt -y autoclean",
          "sudo cloud-init clean",
          "sudo rm -f /etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg",
          "sudo rm -f /etc/netplan/00-installer-config.yaml",
          "sudo sync"
      ]
  }

  # Provisioning the VM Template for Cloud-Init Integration in Proxmox #2
  provisioner "file" {
      source = "files/99-pve.cfg"
      destination = "/tmp/99-pve.cfg"
  }

  # Provisioning the VM Template for Cloud-Init Integration in Proxmox #3
  provisioner "shell" {
      inline = [ "sudo cp /tmp/99-pve.cfg /etc/cloud/cloud.cfg.d/99-pve.cfg" ]
  }
}