variable "azure_region" {
  type        = string
  default     = "uksouth"
  description = "The Azure Region to deploy this collection of resources to."
}
variable "azure_alt_region" {
  type        = string
  default     = "westus2"
  description = "The alternative Azure Region."
}
variable "tags" {
  type        = map(any)
  description = "Tags to be attached to azure resources"
  default = {
    "deployed_by" = "terraform"
    "project"     = "aqua"
    "env"         = "dev"
  }
}
variable "username" {
  description = "Username for Virtual Machines"
  type        = string
  default     = "adminuser"
}
variable "password" {
  description = "Virtual Machine password, must meet Azure complexity requirements"
  type        = string
  default     = "Pa55w0rd123!"
}
variable "vmsize" {
  description = "Size of the VMs"
  type        = string
  default     = "Standard_D4s_v3"
  #default     = "Standard_D8s_v5"
}
variable "rg_aqua_data_collection" {
  description = "Existing RG deployed as part of tcp-to-blob infrastructure"
  type        = string
}
variable "vnet_aqua_data_collection" {
  description = "Existing vNET deployed as part of tcp-to-blob infrastructure"
  type        = string
}
variable "sa_data_collection" {
  description = "Existing Storage Account deployed as part of tcp-to-blob infrastructure"
  type        = string
}
variable "BUILD_AGENT_IP" {
  description = "Variable set by .tfvars to whitelist IP of home public IP for ACLs"
  type        = string
}
variable "AQUA_TOOLS_RG" {
  description = "Variable pulled from GitHub Secret that sets the name of the Resource Group where the existing Storage Account sits"
  type        = string
}
variable "AQUA_TOOLS_SA" {
  description = "Variable pulled from GitHub Secret that sets name of Storage Account where AQUA apps are"
  type        = string
}
