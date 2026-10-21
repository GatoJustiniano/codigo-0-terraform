# codigo-0-terraform

Infraestructura de **asistenciaweb** (frontend + backend en dos VMs Ubuntu 24.04) escrita con distintas herramientas de infraestructura como codigo.

| Carpeta | Herramienta | Nube | Estado |
|---|---|---|---|
| [`terraform/azure/`](terraform/azure/) | Terraform | Azure | Listo |
| [`opentofu/azure/`](opentofu/) | OpenTofu | Azure | Pendiente |
| [`pulumi/azure/`](pulumi/) | Pulumi | Azure | Pendiente |

Basado en la version AWS `codigo-0-terraform-estructurado` de mi compañero de grupo.

## Convenciones

- Cada herramienta guarda su estado con una `key` propia (`<herramienta>/<nube>/asistenciaweb.tfstate`).
- Todas las versiones crean recursos con los mismos nombres (`asistenciaweb-rg`, etc.): destruir una antes de desplegar otra en la misma suscripcion.
- Los valores locales (`terraform.tfvars`, credenciales) no se suben a git.
