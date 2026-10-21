# Salidas
output "frontend_public_ip" {
  description = "IP publica del frontend"
  value       = azurerm_public_ip.frontend.ip_address
}

output "frontend_url" {
  description = "Direccion HTTPS del frontend"
  value       = "https://${azurerm_public_ip.frontend.ip_address}"
}

output "backend_public_ip" {
  description = "IP publica del backend"
  value       = azurerm_public_ip.backend.ip_address
}

output "backend_private_ip" {
  description = "IP privada del backend"
  value       = azurerm_linux_virtual_machine.backend.private_ip_address
}

output "ssh_frontend" {
  description = "Comando SSH al frontend"
  value       = "ssh ${var.admin_username}@${azurerm_public_ip.frontend.ip_address}"
}

output "ssh_backend" {
  description = "Comando SSH al backend"
  value       = "ssh ${var.admin_username}@${azurerm_public_ip.backend.ip_address}"
}
