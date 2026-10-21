# Grupo logico del frontend, usado como origen en las reglas del backend
resource "azurerm_application_security_group" "frontend" {
  name                = "asistenciaweb-frontend-asg"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_network_interface_application_security_group_association" "frontend" {
  network_interface_id          = azurerm_network_interface.frontend.id
  application_security_group_id = azurerm_application_security_group.frontend.id
}

# Seguridad del frontend
resource "azurerm_network_security_group" "frontend" {
  name                = "asistenciaweb-frontend-nsg"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  security_rule {
    name                       = "ssh-ip-autorizada"
    description                = "SSH desde IP autorizada"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.my_ip_cidr
    destination_address_prefix = "*"
  }

  # El frontend es un sitio web publico: HTTPS abierto a Internet es intencional
  #trivy:ignore:AZU-0047
  security_rule {
    name                       = "https-publico"
    description                = "HTTPS publico"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface_security_group_association" "frontend" {
  network_interface_id      = azurerm_network_interface.frontend.id
  network_security_group_id = azurerm_network_security_group.frontend.id
}

# Seguridad del backend
resource "azurerm_network_security_group" "backend" {
  name                = "asistenciaweb-backend-nsg"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  security_rule {
    name                       = "ssh-ip-autorizada"
    description                = "SSH desde IP autorizada"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.my_ip_cidr
    destination_address_prefix = "*"
  }

  security_rule {
    name                                  = "api-desde-frontend"
    description                           = "Comunicacion desde frontend"
    priority                              = 110
    direction                             = "Inbound"
    access                                = "Allow"
    protocol                              = "Tcp"
    source_port_range                     = "*"
    destination_port_range                = "3000"
    source_application_security_group_ids = [azurerm_application_security_group.frontend.id]
    destination_address_prefix            = "*"
  }

  security_rule {
    name                       = "api-publica"
    description                = "Acceso publico al backend"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3000"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface_security_group_association" "backend" {
  network_interface_id      = azurerm_network_interface.backend.id
  network_security_group_id = azurerm_network_security_group.backend.id
}
