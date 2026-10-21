# OpenTofu

Pendiente. Version OpenTofu de la infraestructura de asistenciaweb.

OpenTofu usa el mismo lenguaje HCL que Terraform, asi que se puede partir copiando `terraform/azure/` y ejecutando `tofu init` / `tofu plan` / `tofu apply`.

Usar una `key` de estado distinta en el backend (por ejemplo `opentofu/azure/asistenciaweb.tfstate`) para no pisar el estado de Terraform.
