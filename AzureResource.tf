
# Configure Microsoft Azure Provider

provider "azurerm" {
  version = "=1.24.0"
}



# Data variable of Resource Group

data "azurerm_resource_group" "resource_group" {
  name = "TempRG"
}



# Create DDOS protection plan

resource "azurerm_ddos_protection_plan" "test" {
  name                = "ddospplan"
  location            = "${data.azurerm_resource_group.resource_group.location}"
  resource_group_name = "${data.azurerm_resource_group.resource_group.name}"
}



# Create Virtual Network

resource "azurerm_virtual_network" "network" {
    name                = "VirtualNetwork"
    location            = "${data.azurerm_resource_group.resource_group.location}"
    resource_group_name = "${data.azurerm_resource_group.resource_group.name}"
    address_space       = ["10.0.0.0/16"]

    ddos_protection_plan {
    id     = "${azurerm_ddos_protection_plan.test.id}"
    enable = true
    }
}



# Create Subnet

resource "azurerm_subnet" "subnet" {
    name                 = "Subnet"
    resource_group_name  = "${data.azurerm_resource_group.resource_group.name}"
    virtual_network_name = "${azurerm_virtual_network.network.name}"
    address_prefix       = "10.0.0.0/24"

}



# Create a Public IP

resource "azurerm_public_ip" "publicip" {
    name                         = "PublicIP"
    location                     = "${data.azurerm_resource_group.resource_group.location}"
    resource_group_name          = "${data.azurerm_resource_group.resource_group.name}"
    allocation_method            = "Dynamic"

    tags {
        Application = "Tomcat"
        Environment = "Test"
    }
}




# Create Security Group Rules

resource "azurerm_network_security_group" "networksecuritygroup" {
    name                = "NetworkSecurityGroup"
    location            = "${data.azurerm_resource_group.resource_group.location}"
    resource_group_name = "${data.azurerm_resource_group.resource_group.name}"
    
    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "tomcat"
        priority                   = 1002
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "8080"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    tags {
        Application = "Tomcat"
        Environment = "Test"
    }
}




# Create Network Interface

resource "azurerm_network_interface" "nic" {
    name                      = "NIC"
    location                  = "${data.azurerm_resource_group.resource_group.location}"
    resource_group_name       = "${data.azurerm_resource_group.resource_group.name}"
    network_security_group_id = "${azurerm_network_security_group.networksecuritygroup.id}"

    ip_configuration {
        name                          = "NICConfiguration"
        subnet_id                     = "${azurerm_subnet.subnet.id}"
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = "${azurerm_public_ip.publicip.id}"
    }

    tags {
        Application = "Tomcat"
        Environment = "Test"
    }
}



####


# Create the Virtual Machine

resource "azurerm_virtual_machine" "virtual_machine" {
  name                  = "TomcatInstance"
  location              = "${data.azurerm_resource_group.resource_group.location}"
  resource_group_name   = "${data.azurerm_resource_group.resource_group.name}"
  network_interface_ids = ["${azurerm_network_interface.nic.id}"]
  vm_size               = "Standard_D2s_v3"

 
  delete_os_disk_on_termination = true


  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }
  
  os_profile {
    computer_name  = "TomcatInstance"
    admin_username = "ansible"
    admin_password = "syD26Xu+>3.9"
  }
  
  os_profile_linux_config {
    disable_password_authentication = false
  }
  
  tags {
        Application = "Tomcat"
        Environment = "Test"
    }
}



# Output the public IP address

data "azurerm_public_ip" "publicip" {
  name                = "${azurerm_public_ip.publicip.name}"
  resource_group_name = "${data.azurerm_resource_group.resource_group.name}"
}

output "public_ip_address" {
  value = "${data.azurerm_public_ip.publicip.ip_address}"
}