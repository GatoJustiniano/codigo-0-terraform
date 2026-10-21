# Imagen Ubuntu 24.04 (equivale al data "aws_ami" del proyecto AWS)
locals {
  ubuntu_image = {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }
}
