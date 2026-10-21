// Salidas (equivale a outputs.tf)
import * as pulumi from "@pulumi/pulumi";
import { adminUsername } from "./config";
import { frontend, backend } from "./compute";

export const frontendPublicIp = frontend.publicIp.ipAddress;
export const frontendUrl = pulumi.interpolate`https://${frontend.publicIp.ipAddress}`;
export const backendPublicIp = backend.publicIp.ipAddress;
export const backendPrivateIp = backend.nic.ipConfigurations.apply(
  (configs) => configs?.[0]?.privateIPAddress,
);
export const sshFrontend = pulumi.interpolate`ssh ${adminUsername}@${frontend.publicIp.ipAddress}`;
export const sshBackend = pulumi.interpolate`ssh ${adminUsername}@${backend.publicIp.ipAddress}`;
