locals {
  resource_group = "test-k8s"
  location = "Korea Central"

  storage = {
    storages = [ 
      ["k8steststor", "S", "LRS"],
    ]
    file_share = [
      ["k8stestfile","50"],
    ]
  }

  nsg = {
    nsg_names = ["k8s-NSG01"] 
    nsg_rules = [ 
      ["k8s-NSG01", 100, "port-tcp-22", 22, "*", "tcp"],
      ["k8s-NSG01", 110, "port-tcp-80", 80, "*", "tcp"],
    ],
    nsg_subnet_set = [
      ["k8s-Subnet01", "k8s-NSG01"],
    ]     
  }

  vnet = {
    address_space = ["10.0.0.0/8"]
    subnets = [
      ["k8s-Subnet01", "10.0.0.0/16"]
    ] 
  }


  avset_names = ["k8s-AVset01"]

  vm = {
      public_ips = [
        ["m-k8s-pip", "S", "S"],
        ["w1-k8s-pip", "S", "S"],
        ["w2-k8s-pip", "S", "S"],
        ["w3-k8s-pip", "S", "S"]
      ],
      nics = [
        ["m-k8s-nic", "k8s-Subnet01", "S","10.0.0.100", "m-k8s-pip","false"],
        ["w1-k8s-nic", "k8s-Subnet01", "S","10.0.0.101", "w1-k8s-pip","false"],
        ["w2-k8s-nic", "k8s-Subnet01", "S","10.0.0.102", "w2-k8s-pip", "false"],
        ["w3-k8s-nic", "k8s-Subnet01", "S","10.0.0.103", "w3-k8s-pip", "false"],
      ],
      vms=[
        ["m-k8s", ["m-k8s-nic"], "Standard_F2s", "",["Canonical","UbuntuServer","18.04-LTS","latest"], ["P", 32], "k8steststor", ["tag", "tag1"]],
        ["w1-k8s", ["w1-k8s-nic"], "Standard_F2s", "",["Canonical","UbuntuServer","18.04-LTS","latest"], ["P", 32], "k8steststor", ["tag", "tag2"]],
        ["w2-k8s", ["w2-k8s-nic"], "Standard_F2s", "",["Canonical","UbuntuServer","18.04-LTS","latest"], ["P", 32], "k8steststor", ["tag", "tag2"]],
        ["w3-k8s", ["w3-k8s-nic"], "Standard_F2s", "",["Canonical","UbuntuServer","18.04-LTS","latest"], ["P", 32], "k8steststor", ["tag", "tag2"]],
      ],
      data_disks=[
        ["m-k8s", 0, "m-k8s-disk-data-0", "H", 32, "ReadWrite"],
        ["w1-k8s", 0, "w1-k8s-disk-data-0", "H", 32, "ReadWrite"],
        ["w2-k8s", 0, "w2-k8s-disk-data-0", "H", 32, "ReadWrite"],
        ["w3-k8s", 0, "w3-k8s-disk-data-0", "H", 32, "ReadWrite"]
      ],
      extension=[
      ["nginx_hostname","Microsoft.Azure.Extensions","CustomScript","2.0","apt-get -y update"],
      ["nginx_hostname","Microsoft.Azure.Extensions","CustomScript","2.0","apt-get -y update"],
      ["nginx_hostname","Microsoft.Azure.Extensions","CustomScript","2.0","apt-get -y update"],
      ["nginx_hostname","Microsoft.Azure.Extensions","CustomScript","2.0","apt-get -y update"],
    ]
  }
}

module "resource_group" {
  source = "./resource_group"  
  name = local.resource_group
  location = local.location
}

module "storage" {
  source = "./storage"
  
  resource_group_name = module.resource_group.name
  location = module.resource_group.location
  storages = local.storage.storages
  fileshare = local.storage.file_share
}

module "nsg" {
  source = "./nsg/nsg"

  location = module.resource_group.location
  resource_group_name = module.resource_group.name

  nsg_names = local.nsg.nsg_names
  nsg_rules = local.nsg.nsg_rules
}

module "vnet" {
  source = "./vnet"  
  vnet_name = "k8s-VNet01"      
  location = module.resource_group.location
  resource_group_name = module.resource_group.name
  address_space = local.vnet.address_space
  subnets = local.vnet.subnets
}

module "nsg_subnet_set" {
  source = "./nsg/nsg_subnet_set"

  nsg_id = module.nsg.id
  subnet_id = module.vnet.subnet_id
  nsg_subnet_set = local.nsg.nsg_subnet_set
}


module "avset" {
  source = "./avset"
  resource_group_name = module.resource_group.name
  location = module.resource_group.location
  avset_names = local.avset_names
}

module "pip" {
  source = "./pip"

  resource_group_name = module.resource_group.name
  location = module.resource_group.location
  public_ips = local.vm.public_ips
}

module "nic" {
  source = "./nic"

  resource_group_name = module.resource_group.name
  location = module.resource_group.location
  subnet_id = module.vnet.subnet_id
  pip_id = module.pip.id
  nics = local.vm.nics
}


module "vm" {
  source = "./vm/vm"

  resource_group_name = module.resource_group.name
  location = module.resource_group.location
  nic_id = module.nic.id
  avset_id = module.avset.id
  admin_username = "azureuser"
  admin_password = "Azurexptmxm123"
  vms = local.vm.vms
  extension = local.vm.extension
}

module "data_disk" {
  source = "./vm/disk/data_disk_create_attach"

  resource_group_name = module.resource_group.name
  location = module.resource_group.location
  disks = local.vm.data_disks
  vm_id = module.vm.id
}


# module "data_disk_create" {
#    source = "./vm/disk/data_disk"

#   resource_group_name = module.resource_group.name
#   location = module.resource_group.location
# }

# module "data_disk_attach" {
#    source = "./vm/disk/data_disk_attach"

#   resource_group_name = module.resource_group.name
#   location = module.resource_group.location
#   data_disk_id = module.data_disk_create.id
#   vm_id = module.vm.id
# }


output "avset_id" {
  value = module.avset.id
}


output "nic_id" {
  value = module.nic.id
}

output "nsg_id" {
  value = module.nsg.id
}

output "nsg_subnet_set_info" {
  value = module.nsg_subnet_set.info
}

output "pip_id" {
  value = module.pip.id
}

output "vnet_name" {
  value = module.vnet.name
}

output "subnet_id" {
  value = module.vnet.subnet_id
}

output "resource_group_id" {
  value = module.resource_group.id
}

output "resource_group_name" {
  value = module.resource_group.name
}

output "resource_group_location" {
  value = module.resource_group.location
}

output "storage_id" {
  value = module.storage.id
}
output "storage_name" {
  value = module.storage.storagename
}

output "storage_file_share_name" {
  value = module.storage.filesharename
}




