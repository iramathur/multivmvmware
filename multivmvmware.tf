provider "vsphere" {
  user           = "cmpqa.svc@itomcmp.servicenow.com"
  password       = "snc!23$"
  vsphere_server = "10.198.1.13"
  version = "< 1.16.0"
  # If you have a self-signed cert
  allow_unverified_ssl = true
}

data "vsphere_datacenter" "dc" {
  name = "devcloud"
}

data "vsphere_datastore" "datastore" {
  name          = "vmstore"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_resource_pool" "pool" {
  name          = "fenrir/Resources"
 datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_network" "network" {
  name          = "portGroup-1004"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

resource "vsphere_virtual_machine" "vm" {
  name             = "terraform-test"
  resource_pool_id     = "${data.vsphere_resource_pool.pool.id}"
  datastore_id     = "${data.vsphere_datastore.datastore.id}"
  wait_for_guest_net_timeout = -1
  folder               = "dev_zone"
  num_cpus = 2
  memory   = 1024
  guest_id = "ubuntu16"

  network_interface {
    network_id = "${data.vsphere_network.network.id}"
  }

  disk {
    label = "terraform-test-disk.vmdk"
    size = "30"
    thin_provisioned = "${data.vsphere_virtual_machine.template.disks.0.thin_provisioned}"
  }
}
