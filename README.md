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

## Calidad y buenas practicas

`scripts/calidad.ps1` ejecuta todo de una vez sobre `terraform/azure/` (y compila `pulumi/azure/`):

| Herramienta | Que revisa |
|---|---|
| `terraform fmt` / `terraform validate` | Formato y sintaxis |
| [TFLint](https://github.com/terraform-linters/tflint) + ruleset `azurerm` | Buenas practicas de Terraform y valores invalidos de Azure (`.tflint.hcl`) |
| [Trivy](https://trivy.dev) (`trivy config`) | Configuraciones inseguras (reemplaza a tfsec, que ya no se mantiene) |
| [Checkov](https://www.checkov.io) | Politicas de seguridad y cumplimiento |
| `tsc` | Tipos del proyecto Pulumi |

Instalacion (una vez):

```bash
winget install TerraformLinters.tflint
winget install AquaSecurity.Trivy
python -m venv $HOME\.venvs\checkov
& $HOME\.venvs\checkov\Scripts\python.exe -m pip install checkov
```

Ejecucion:

```bash
powershell -ExecutionPolicy Bypass -File scripts\calidad.ps1
```

Las excepciones intencionales estan justificadas en el codigo con `#trivy:ignore:<id>` y `#checkov:skip=<id>:<motivo>` (IPs publicas en las NICs, HTTPS publico en el frontend y NSG por NIC en vez de por subred).
