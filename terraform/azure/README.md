# asistenciaweb en Azure (Terraform)

Version Azure de la infraestructura de `codigo-0-terraform-estructurado` (AWS, hecho por mi compañero de grupo).
Crea una red virtual con una subred publica, dos VMs Ubuntu 24.04 (frontend y backend) con IP publica y sus reglas de firewall.

| AWS | Azure |
|---|---|
| VPC + subnet + IGW + route table | Resource group + VNet + subnet (la salida a Internet va por la IP publica de cada VM) |
| `aws_instance` | `azurerm_linux_virtual_machine` + NIC + IP publica |
| `data "aws_ami"` | `source_image_reference` (Canonical `ubuntu-24_04-lts`) |
| Security groups | Network security groups + application security group del frontend |
| Key pair | Clave publica SSH local |
| Backend S3 | Backend `azurerm` (Storage Account) |

## Requisitos

- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.5
- [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli)
- Una clave SSH (`ssh-keygen -t ed25519` si no tienes `~/.ssh/id_ed25519.pub`)

## Pasos

1. Iniciar sesion: `az login`
2. Crear una sola vez el almacenamiento del estado (el nombre del storage account debe ser unico en Azure; si cambia, actualizar `backend.tf`):

   ```bash
   az group create -n asistenciaweb-tfstate-rg -l mexicocentral
   az storage account create -n tfstateasistenciaweb -g asistenciaweb-tfstate-rg -l mexicocentral --sku Standard_LRS
   az storage container create -n tfstate --account-name tfstateasistenciaweb --auth-mode key
   ```

3. Copiar `terraform.example.tfvars` a `terraform.tfvars` y completar `subscription_id` (`az account show --query id -o tsv`) y `my_ip_cidr` (tu IP publica con `/32`).
4. `terraform init`
5. `terraform plan`
6. `terraform apply`

Para borrar todo: `terraform destroy`.

## Cuenta gratuita

- En la suscripcion de prueba `Standard_B1s` no esta disponible en las regiones comunes y `eastus` bloquea los tamanos B. Por eso se usa `mexicocentral` con `Standard_B2ats_v2` en ambas VMs.
- La prueba permite 4 vCPU por region: 2 VMs x 2 vCPU llega justo al limite.
- 750 h/mes de B2ats_v2 son gratuitas; la segunda VM se descuenta del credito de prueba.
- Los discos de 64 GB Premium SSD (P6) estan cubiertos (dos incluidos).
- Para revisar otra region: `az vm list-skus --location <region> --size Standard_B2ats_v2 --all -o json` (sin `restrictions` = disponible) y `az vm list-usage --location <region> -o table` (cuota de vCPU).
- Apaga o destruye las VMs cuando no las uses, y ejecuta `terraform destroy` antes de que termine la prueba.
