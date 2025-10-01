terraform {
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
      version = "0.8.3"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}

# libvirt_pool to specify where the volume will reside
resource "libvirt_pool" "pool-1" {
  name = "pool-1"
  type = "dir"
  target {
    path = "/mnt/data/libvirt_pool_1"
  }
}

# resource "libvirt_network" "default" {
#   name = "default"
#   mode = "nat"
#   autostart = true
#   addresses = ["192.168.101.1/24"]  # Gateway address and subnet for network

#   dhcp {
#     enabled = true
#   }
# }

locals {
    # vm_names = ["talos-1"]
  vm_names = ["talos-1", "talos-2", "talos-3"]
}

resource "libvirt_volume" "vm_disk" {
  for_each = toset(local.vm_names)
  name     = "vm-disk-${each.key}.qcow2"
  pool     = libvirt_pool.pool-1.name
  format   = "qcow2"
  size     = 25 * 1024 * 1024 * 1024  # 25 GiB
}
resource "libvirt_volume" "vm_disk_application_data" {
  for_each = toset(local.vm_names)
  name     = "vm-disk-${each.key}-application-data.qcow2"
  pool     = libvirt_pool.pool-1.name
  format   = "qcow2"
  size     = 25 * 1024 * 1024 * 1024  # 25 GiB
}


resource "libvirt_domain" "vm" {
  for_each = toset(local.vm_names)
  name     = each.key
  # memory   = 8192
  memory   = 16384
  vcpu     = 4
#   qemu_agent = true
#   autostart  = true

  network_interface {
    network_name = "default"
    # addresses    = [local.vm_ips[each.key]]
  }

  disk {
    volume_id = libvirt_volume.vm_disk[each.key].id
  }
  disk {
    volume_id = libvirt_volume.vm_disk_application_data[each.key].id
  }
  disk {
    file = "/home/uri/Documents/talos-metal-amd64.iso"
  }
#   depends_on = [libvirt_network.default]
  boot_device {
    dev = ["cdrom", "hd"]  # boot from cdrom first, then hd, then network
  }
  cpu {
    mode = "host-passthrough"
  }
    # Override machine type to pc-q35
    machine = "pc-q35-10.0"
  xml {
    xslt = file("add_spicevmc.xsl")
  }
  video {
    type = "virtio"
  }

}



# # libvirt_volume for VM
# resource "libvirt_volume" "vm_disk_1" {
#   name = "vm-disk-1.qcow2"
#   pool = "pool-1"
#   format = "qcow2"
#   size   = 25 * 1024 * 1024 * 1024  # 10 GiB
# }

# # the VM
# resource "libvirt_domain" "talos-1" {
#   name = "talos-1"
#   memory = "8192"
#   vcpu   = 4
#   qemu_agent = true
#   autostart = true
#   network_interface {
#     network_name = "default"
#   }
#   disk {
#     volume_id = libvirt_volume.vm_disk_1.id
#   }
#   disk {
#     file = "/home/uri/Documents/talos-metal-amd64.iso"
#   }
# }