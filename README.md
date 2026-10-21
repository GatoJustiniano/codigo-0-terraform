# codigo-0-terraform

Infraestructura de **asistenciaweb** (frontend + backend en dos VMs Ubuntu 24.04) escrita con distintas herramientas de infraestructura como codigo.

| Carpeta | Herramienta | Nube | Estado |
|---|---|---|---|
| [`terraform/azure/`](terraform/azure/) | Terraform | Azure | Listo |
| [`opentofu/azure/`](opentofu/) | OpenTofu | Azure | Pendiente |
| [`pulumi/azure/`](pulumi/azure/) | Pulumi (TypeScript) | Azure | Listo |

Basado en la version AWS `codigo-0-terraform-estructurado` de mi compañero de grupo.

## Convenciones

- Cada herramienta guarda su estado por separado en el mismo storage account (Terraform: key `terraform/azure/...` en el container `tfstate`; Pulumi: container `pulumistate`).
- Cada version usa su propio grupo de recursos (`asistenciaweb-rg`, `asistenciaweb-pulumi-rg`), pero la suscripcion de prueba solo permite 4 vCPU por region y cada version usa 4: destruir una antes de desplegar otra en la misma region.
- Los valores locales (`terraform.tfvars`, `Pulumi.<stack>.yaml`, credenciales) no se suben a git.
