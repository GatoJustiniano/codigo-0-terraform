# Grupo de recursos
resource "azurerm_resource_group" "main" {
  name     = "asistenciaweb-rg"
  location = var.location
}

# Red
resource "azurerm_virtual_network" "main" {
  name                = "asistenciaweb-vnet"
  address_space       = [var.vnet_cidr]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_subnet" "public" {
  #checkov:skip=CKV2_AZURE_31:Frontend y backend comparten subred con reglas distintas; el NSG se asocia a cada NIC (security.tf)
  name                 = "asistenciaweb-subnet-publica"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.public_subnet_cidr]
}

# IPs publicas (Standard: la SKU Basic ya fue retirada)
resource "azurerm_public_ip" "frontend" {
  name                = "asistenciaweb-frontend-ip"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_public_ip" "backend" {
  name                = "asistenciaweb-backend-ip"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Interfaces de red
# Las IPs publicas son parte del diseno (no hay balanceador ni bastion); el acceso lo limita el NSG
#trivy:ignore:AZU-0076
resource "azurerm_network_interface" "frontend" {
  #checkov:skip=CKV_AZURE_119:IP publica necesaria para servir la web y para SSH desde la IP autorizada
  name                = "asistenciaweb-frontend-nic"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "interna"
    subnet_id                     = azurerm_subnet.public.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.frontend.id
  }
}

#trivy:ignore:AZU-0076
resource "azurerm_network_interface" "backend" {
  #checkov:skip=CKV_AZURE_119:IP publica necesaria para SSH desde la IP autorizada y la API publica en el puerto 3000
  name                = "asistenciaweb-backend-nic"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "interna"
    subnet_id                     = azurerm_subnet.public.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.backend.id
  }
}
