import * as pulumi from "@pulumi/pulumi";
import * as azure from "@pulumi/azure-native";
import { location, vnetCidr, publicSubnetCidr } from "./config";

// Grupo de recursos (nombre distinto al de Terraform para que no choquen)
export const resourceGroup = new azure.resources.ResourceGroup("main", {
  resourceGroupName: "asistenciaweb-pulumi-rg",
  location,
});

// Red: la subred se declara dentro de la VNet para que Pulumi no la borre al actualizar la VNet
export const vnet = new azure.network.VirtualNetwork("main", {
  virtualNetworkName: "asistenciaweb-vnet",
  resourceGroupName: resourceGroup.name,
  location,
  addressSpace: { addressPrefixes: [vnetCidr] },
  subnets: [
    {
      name: "asistenciaweb-subnet-publica",
      addressPrefix: publicSubnetCidr,
    },
  ],
});

export const publicSubnetId: pulumi.Output<string> = vnet.subnets.apply(
  (subnets) => subnets![0].id!,
);
