import * as azure from "@pulumi/azure-native";
import { location, myIpCidr } from "./config";
import { resourceGroup } from "./network";

// Grupo logico del frontend, usado como origen en las reglas del backend
export const frontendAsg = new azure.network.ApplicationSecurityGroup("frontend", {
  applicationSecurityGroupName: "asistenciaweb-frontend-asg",
  resourceGroupName: resourceGroup.name,
  location,
});

const sshRule = {
  name: "ssh-ip-autorizada",
  description: "SSH desde IP autorizada",
  priority: 100,
  direction: "Inbound",
  access: "Allow",
  protocol: "Tcp",
  sourcePortRange: "*",
  destinationPortRange: "22",
  sourceAddressPrefix: myIpCidr,
  destinationAddressPrefix: "*",
};

// Seguridad del frontend
export const frontendNsg = new azure.network.NetworkSecurityGroup("frontend", {
  networkSecurityGroupName: "asistenciaweb-frontend-nsg",
  resourceGroupName: resourceGroup.name,
  location,
  securityRules: [
    sshRule,
    {
      name: "https-publico",
      description: "HTTPS publico",
      priority: 110,
      direction: "Inbound",
      access: "Allow",
      protocol: "Tcp",
      sourcePortRange: "*",
      destinationPortRange: "443",
      sourceAddressPrefix: "Internet",
      destinationAddressPrefix: "*",
    },
  ],
});

// Seguridad del backend
export const backendNsg = new azure.network.NetworkSecurityGroup("backend", {
  networkSecurityGroupName: "asistenciaweb-backend-nsg",
  resourceGroupName: resourceGroup.name,
  location,
  securityRules: [
    sshRule,
    {
      name: "api-desde-frontend",
      description: "Comunicacion desde frontend",
      priority: 110,
      direction: "Inbound",
      access: "Allow",
      protocol: "Tcp",
      sourcePortRange: "*",
      destinationPortRange: "3000",
      sourceApplicationSecurityGroups: [{ id: frontendAsg.id }],
      destinationAddressPrefix: "*",
    },
    {
      name: "api-publica",
      description: "Acceso publico al backend",
      priority: 120,
      direction: "Inbound",
      access: "Allow",
      protocol: "Tcp",
      sourcePortRange: "*",
      destinationPortRange: "3000",
      sourceAddressPrefix: "Internet",
      destinationAddressPrefix: "*",
    },
  ],
});
