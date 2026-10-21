# Imagen Ubuntu 24.04 (equivale al data "aws_ami" del proyecto AWS)
locals {
  ubuntu_image = {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }
}

# VM: Frontend
resource "azurerm_linux_virtual_machine" "frontend" {
  name                  = "asistenciaweb-frontend"
  location              = azurerm_resource_group.main.location
  resource_group_name   = azurerm_resource_group.main.name
  size                  = var.frontend_vm_size
  admin_username        = var.admin_username
  network_interface_ids = [azurerm_network_interface.frontend.id]

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(pathexpand(var.ssh_public_key_path))
  }

  # 64 GB Premium SSD = disco P6, incluido en la cuenta gratuita
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = 64
  }

  source_image_reference {
    publisher = local.ubuntu_image.publisher
    offer     = local.ubuntu_image.offer
    sku       = local.ubuntu_image.sku
    version   = local.ubuntu_image.version
  }
}

# VM: Backend
resource "azurerm_linux_virtual_machine" "backend" {
  name                  = "asistenciaweb-backend"
  location              = azurerm_resource_group.main.location
  resource_group_name   = azurerm_resource_group.main.name
  size                  = var.backend_vm_size
  admin_username        = var.admin_username
  network_interface_ids = [azurerm_network_interface.backend.id]

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(pathexpand(var.ssh_public_key_path))
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = 64
  }

  source_image_reference {
    publisher = local.ubuntu_image.publisher
    offer     = local.ubuntu_image.offer
    sku       = local.ubuntu_image.sku
    version   = local.ubuntu_image.version
  }
}
