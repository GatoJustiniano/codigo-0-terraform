# asistenciaweb en Azure (Pulumi + TypeScript)

Misma infraestructura que [`terraform/azure/`](../../terraform/azure/), escrita con Pulumi en TypeScript:
una red virtual con una subred publica, dos VMs Ubuntu 24.04 (frontend y backend) con IP publica y sus reglas de firewall.

| Terraform | Pulumi |
|---|---|
| `variables.tf` + `terraform.tfvars` | `config.ts` + `pulumi config set` |
| `network.tf` | `network.ts` (la subred va dentro de la VNet) |
| `security.tf` | `security.ts` (la regla SSH se reutiliza como objeto) |
| `compute.tf` (IP + NIC + VM repetidos por VM) | `compute.ts` (funcion `createServer` llamada dos veces) |
| `outputs.tf` | `export` en `index.ts` |
| Backend `azurerm` | Backend `azblob` en el mismo storage account |
| Asociaciones NIC-NSG / NIC-ASG | Propiedades de la NIC |

El grupo de recursos se llama `asistenciaweb-pulumi-rg` para no chocar con el de Terraform.

## Requisitos

- [Pulumi CLI](https://www.pulumi.com/docs/install/): `winget install Pulumi.Pulumi`
- Node.js 18 o superior
- Azure CLI con sesion iniciada (`az login`)
- El storage account del estado ya creado (ver README de Terraform)
- Clave SSH en `~/.ssh/id_ed25519.pub`

## Cuota de la suscripcion de prueba

La prueba permite 4 vCPU por region y cada version usa 4 (2 VMs x 2 vCPU).
**Antes de desplegar con Pulumi, ejecutar `terraform destroy` en `terraform/azure/`** (o desplegar en otra region con `pulumi config set location <region>`).

## Pasos (PowerShell)

1. Instalar dependencias:

   ```bash
   npm install
   ```

2. Crear una sola vez el container del estado de Pulumi:

   ```bash
   az storage container create -n pulumistate --account-name tfstateasistenciaweb --auth-mode key
   ```

3. En cada terminal nueva (se pierden al cerrarla), definir las variables del backend y la frase que cifra los secretos del stack (elegir una y no perderla). Sin ellas `pulumi` falla con `Options.AccountName is required`:

   ```powershell
   $env:AZURE_STORAGE_ACCOUNT = "tfstateasistenciaweb"
   $env:AZURE_STORAGE_KEY = az storage account keys list -n tfstateasistenciaweb -g asistenciaweb-tfstate-rg --query "[0].value" -o tsv
   $env:PULUMI_CONFIG_PASSPHRASE = "<tu frase>"
   ```

4. Iniciar sesion en el backend y crear el stack:

   ```bash
   pulumi login "azblob://pulumistate?storage_account=tfstateasistenciaweb"
   pulumi stack init dev
   ```

5. Configurar (se guarda en `Pulumi.dev.yaml`, que no se sube a git):

   ```bash
   pulumi config set myIpCidr <tu IP>/32
   ```

   Opcionales: `location` (por defecto `westus2`), `frontendVmSize` / `backendVmSize` (por defecto `Standard_B2ts_v2`), `sshPublicKeyPath`, `adminUsername`.
   Pulumi usa la suscripcion activa de `az account show`; para fijar otra: `pulumi config set azure-native:subscriptionId <id>`.

6. Revisar y desplegar:

   ```bash
   pulumi preview
   pulumi up
   ```

7. Ver salidas y conectarse:

   ```bash
   pulumi stack output
   ```

Para borrar todo: `pulumi destroy`.
