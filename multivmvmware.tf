provider "vsphere" {
  user           = "cmpqa.svc@itomcmp.servicenow.com"
  password       = "snc!23$"
  vsphere_server = "10.198.1.13"

  # If you have a self-signed cert
  allow_unverified_ssl = true
}

#### RETRIEVE DATA INFORMATION ON VCENTER ####
data "vsphere_datacenter" "dc" {
  name = "devcloud"
}

data "vsphere_resource_pool" "pool" {
  name          = "fenrir/Resources"
 datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

# Retrieve datastore information on vsphere
data "vsphere_datastore" "datastore" {
  name          = "vmstore"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

# Retrieve network information on vsphere
data "vsphere_network" "network" {
  name          = "portGroup-1004"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

# Retrieve template information on vsphere
data "vsphere_virtual_machine" "template" {
  name          = "ubuntu16"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

# Set vm parameters
resource "vsphere_virtual_machine" "vm-one" {
  count = 2
  name                 = "vm-multi-${count.index}"
  num_cpus             = 2
  memory               = 4096
  datastore_id         = "${data.vsphere_datastore.datastore.id}"
  #host_system_id       = "${data.vsphere_host.host.id}"
  resource_pool_id     = "${data.vsphere_resource_pool.pool.id}"
  guest_id             = "${data.vsphere_virtual_machine.template.guest_id}"
  scsi_type            = "${data.vsphere_virtual_machine.template.scsi_type}"
  # Set network parameters
  network_interface {
    network_id         = "${data.vsphere_network.network.id}"
  }
  # Use a predefined vmware template has main disk
  disk {
    label = "vm-multi-${count.index}.vmdk"
    size = "30"
    thin_provisioned = "${data.vsphere_virtual_machine.template.disks.0.thin_provisioned}"
  }
  clone {
    template_uuid = "${data.vsphere_virtual_machine.template.id}"
    customize {
      linux_options {
        host_name = "vm-multi-${count.index}"
        domain    = "test.internal"
      }
      network_interface {
      }
      ipv4_gateway = "10.198.4.1"
    }

  }

}
