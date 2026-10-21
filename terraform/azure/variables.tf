variable "subscription_id" {
  description = "ID de la suscripcion de Azure (az account show --query id -o tsv)"
  type        = string
}

variable "location" {
  description = "Region de Azure"
  type        = string
  default     = "eastus"
}

variable "vnet_cidr" {
  description = "Bloque CIDR de la red virtual"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "Bloque CIDR de la subred pública"
  type        = string
  default     = "10.0.1.0/24"
}

variable "my_ip_cidr" {
  description = "IP publica autorizada para SSH (ej. 1.2.3.4/32)"
  type        = string
}

variable "admin_username" {
  description = "Usuario administrador de las VMs"
  type        = string
  default     = "azureuser"
}

variable "ssh_public_key_path" {
  description = "Ruta a la clave publica SSH local"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

# Cuenta gratuita: 750 h/mes de cada tamano, por eso se usa uno distinto por VM
variable "frontend_vm_size" {
  description = "Tamano de la VM del frontend"
  type        = string
  default     = "Standard_B1s"
}

variable "backend_vm_size" {
  description = "Tamano de la VM del backend"
  type        = string
  default     = "Standard_B2ats_v2"
}
