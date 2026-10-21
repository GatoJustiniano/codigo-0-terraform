// Configuracion del stack (equivale a variables.tf)
// Se define con: pulumi config set <clave> <valor>
import * as pulumi from "@pulumi/pulumi";
import * as fs from "fs";
import * as os from "os";

const config = new pulumi.Config();

export const location = config.get("location") ?? "westus2";
export const vnetCidr = config.get("vnetCidr") ?? "10.0.0.0/16";
export const publicSubnetCidr = config.get("publicSubnetCidr") ?? "10.0.1.0/24";

// IP publica autorizada para SSH (ej. 1.2.3.4/32)
export const myIpCidr = config.require("myIpCidr");

export const adminUsername = config.get("adminUsername") ?? "azureuser";

const sshPublicKeyPath = config.get("sshPublicKeyPath") ?? "~/.ssh/id_ed25519.pub";
export const sshPublicKey = fs
  .readFileSync(sshPublicKeyPath.replace(/^~/, os.homedir()), "utf8")
  .trim();

// Suscripcion de prueba: B1s bloqueado y B2ats_v2 sin capacidad en westus2; B2ts_v2 si (2 x 2 vCPU = limite de 4)
export const frontendVmSize = config.get("frontendVmSize") ?? "Standard_B2ts_v2";
export const backendVmSize = config.get("backendVmSize") ?? "Standard_B2ts_v2";
