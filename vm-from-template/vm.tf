provider "vsphere" {
  vsphere_server       = var.vsphere_vcenter
  user                 = var.vsphere_user
  password             = var.vsphere_password
  allow_unverified_ssl = true
}

data "vsphere_datacenter" "datacenter" {
  name = "T-Systems"
}

data "vsphere_datastore" "datastore" {
  #name          = "DS4200-2"
  name          = var.vsphere_datastore
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

#data "vsphere_datastore_cluster" "datastore_cluster" {
#  name          = "datastore-cluster-01"
#  datacenter_id = data.vsphere_datacenter.datacenter.id
#}

data "vsphere_compute_cluster" "cluster" {
  #name          = "CAS"
  name          = var.vsphere_cluster
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_network" "network" {
  #name          = "VM Network"
  name          = var.vsphere_network
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

# Retrieve template information on vsphere
data "vsphere_virtual_machine" "template" {
  #name          = "ubuntu2004"
  name          = var.vm_template_name
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

resource "vsphere_virtual_machine" "vm" {
  #name             = "web-server11"
  name             = var.vm_name
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id
  #datastore_cluster_id = data.vsphere_datastore_cluster.datastore_cluster.id
  #num_cpus                   = 1
  num_cpus = var.vm_cpu_nos
  #memory                     = 1024
  memory    = var.vm_mem_size
  guest_id  = data.vsphere_virtual_machine.template.guest_id
  scsi_type = data.vsphere_virtual_machine.template.scsi_type
  #guest_id                   = "centos7_64Guest"
  #guest_id                   = var.vm_guest_id
  #enable_disk_uuid           = true
  wait_for_guest_net_timeout = 0
  network_interface {
    network_id = data.vsphere_network.network.id
    #ipv4_address       = "192.168.200.48"
    #ipv4_prefix_length = 24
    #ipv4_netmask = 24
    #ipv4_gateway = "192.168.200.1"
  }
  disk {
    #label            = "centos7"
    label = var.vm_disk_label
    #size             = 80
    size             = var.vm_disk_size
    eagerly_scrub    = false
    thin_provisioned = true
  }
  clone {
    template_uuid = data.vsphere_virtual_machine.template.id

    customize {
      linux_options {
        host_name = "ubuntu2004"
        domain    = "ubuntu2004.example.com"
      }

      network_interface {
        ipv4_address    = "192.168.200.48"
        ipv4_netmask    = 24
        dns_server_list = ["192.168.200.1", "8.8.8.8"]
      }

      ipv4_gateway = "192.168.200.1"
    }
  }

  # Execute script on remote vm after this creation
  #provisioner "remote-exec" {
  #script = "scripts/example-script.sh"
  #connection {
  #type     = "ssh"
  #user     = "root"
  #password = "VMware1!"
  #host     = vsphere_virtual_machine.demo.default_ip_address 
  #}
  #}
}

