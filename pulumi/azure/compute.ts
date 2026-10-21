import * as pulumi from "@pulumi/pulumi";
import * as azure from "@pulumi/azure-native";
import { location, adminUsername, sshPublicKey, frontendVmSize, backendVmSize } from "./config";
import { resourceGroup, publicSubnetId } from "./network";
import { frontendAsg, frontendNsg, backendNsg } from "./security";

interface ServerArgs {
  size: string;
  nsgId: pulumi.Input<string>;
  asgIds?: pulumi.Input<string>[];
}

// IP publica + interfaz de red + VM Ubuntu 24.04 (en Terraform se repite por cada VM)
function createServer(role: string, args: ServerArgs) {
  const name = `asistenciaweb-${role}`;

  // Standard: la SKU Basic ya fue retirada
  const publicIp = new azure.network.PublicIPAddress(`${role}-ip`, {
    publicIpAddressName: `${name}-ip`,
    resourceGroupName: resourceGroup.name,
    location,
    sku: { name: "Standard" },
    publicIPAllocationMethod: "Static",
  });

  const nic = new azure.network.NetworkInterface(`${role}-nic`, {
    networkInterfaceName: `${name}-nic`,
    resourceGroupName: resourceGroup.name,
    location,
    networkSecurityGroup: { id: args.nsgId },
    ipConfigurations: [
      {
        name: "interna",
        subnet: { id: publicSubnetId },
        privateIPAllocationMethod: "Dynamic",
        publicIPAddress: { id: publicIp.id },
        applicationSecurityGroups: args.asgIds?.map((id) => ({ id })),
      },
    ],
  });

  const vm = new azure.compute.VirtualMachine(role, {
    vmName: name,
    resourceGroupName: resourceGroup.name,
    location,
    hardwareProfile: { vmSize: args.size },
    networkProfile: {
      networkInterfaces: [{ id: nic.id, primary: true }],
    },
    osProfile: {
      computerName: name,
      adminUsername,
      linuxConfiguration: {
        disablePasswordAuthentication: true,
        ssh: {
          publicKeys: [
            {
              path: `/home/${adminUsername}/.ssh/authorized_keys`,
              keyData: sshPublicKey,
            },
          ],
        },
      },
    },
    storageProfile: {
      imageReference: {
        publisher: "Canonical",
        offer: "ubuntu-24_04-lts",
        sku: "server",
        version: "latest",
      },
      // 64 GB Premium SSD = disco P6, incluido en la cuenta gratuita
      osDisk: {
        name: `${name}-osdisk`,
        createOption: "FromImage",
        caching: "ReadWrite",
        diskSizeGB: 64,
        managedDisk: { storageAccountType: "Premium_LRS" },
        deleteOption: "Delete",
      },
    },
  });

  return { publicIp, nic, vm };
}

export const frontend = createServer("frontend", {
  size: frontendVmSize,
  nsgId: frontendNsg.id,
  asgIds: [frontendAsg.id],
});

export const backend = createServer("backend", {
  size: backendVmSize,
  nsgId: backendNsg.id,
});
