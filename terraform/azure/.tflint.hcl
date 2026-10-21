# Reglas de calidad de TFLint (ejecutar `tflint --init` una vez para descargar los plugins)
config {
  call_module_type = "local"
}

# Buenas practicas generales de Terraform (nombres, variables sin uso, versiones, etc.)
plugin "terraform" {
  enabled = true
  preset  = "all"
}

# Reglas especificas de Azure (tamanos de VM, SKUs y valores invalidos)
plugin "azurerm" {
  enabled = true
  version = "0.32.0"
  source  = "github.com/terraform-linters/tflint-ruleset-azurerm"
}
