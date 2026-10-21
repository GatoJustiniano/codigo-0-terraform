# Estado remoto en Azure Storage (crear antes con los comandos del README)
# El nombre del storage account debe ser unico en todo Azure: cambialo si ya existe
terraform {
  backend "azurerm" {
    resource_group_name  = "asistenciaweb-tfstate-rg"
    storage_account_name = "tfstateasistenciaweb"
    container_name       = "tfstate"
    key                  = "terraform/azure/asistenciaweb.tfstate"
  }
}
