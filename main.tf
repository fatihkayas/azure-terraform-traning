provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

resource "azurerm_resource_group" "grafana_rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "grafana_vnet" {
  name                = "grafana-vnet"
  location            = azurerm_resource_group.grafana_rg.location
  resource_group_name = azurerm_resource_group.grafana_rg.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "grafana_subnet" {
  name                 = "grafana-subnet"
  resource_group_name  = azurerm_resource_group.grafana_rg.name
  virtual_network_name = azurerm_virtual_network.grafana_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "grafana_nsg" {
  name                = "grafana-nsg"
  location            = azurerm_resource_group.grafana_rg.location
  resource_group_name = azurerm_resource_group.grafana_rg.name

  security_rule {
    name                       = "AllowSSH"
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
    name                       = "AllowHTTP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "grafana_nic" {
  name                = "grafana-nic"
  location            = azurerm_resource_group.grafana_rg.location
  resource_group_name = azurerm_resource_group.grafana_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.grafana_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "grafana_vm" {
  name                  = "grafana-vm"
  resource_group_name   = azurerm_resource_group.grafana_rg.name
  location              = azurerm_resource_group.grafana_rg.location
  size                  = var.vm_size
  admin_username        = "azureuser"
  network_interface_ids = [azurerm_network_interface.grafana_nic.id]

  admin_ssh_key {
    username   = "azureuser"
    public_key = file(var.public_key_path) # Using an existing public key file
  }


  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}



