variable "azure_region" {
  type        = string
  default     = "westus2"
  description = "The Azure Region to deploy this collection of resources to."
}

variable "azure_failover_region" {
  type        = string
  default     = "ukwest"
  description = "The failover Azure Region."
}

variable "tags" {
  type        = map(any)
  description = "Tags to be attached to azure resources"
  default = {
    "deployed_by" = "terraform"
    "project"     = "orbital_aqua"
    "env"         = "dev"
  }
}

variable "virtual_network_address_space" {
  type        = string
  default     = "10.0.0.0/16"
  description = "A CIDR based address space for the Virtual Network to use. PLEASE NOTE: The /16 bitmask should not be changed as we use this for subnet calculation."
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
  default     = "Standard_FX4mds"
  #default     = "Standard_D8s_v5"
}

variable "rg_name" {
  description = "Variable pulled from GitHub Secret that sets the name of the Resource Group where the existing Storage Account sits"
  type        = string
  default     = "rg-persistent"
}

variable "BUILD_AGENT_IP" {
  description = "Variable set by .tfvars to whitelist IP of home public IP for ACLs"
  type        = string
}

variable "AQUA_TOOLS_SA" {
  description = "Variable pulled from GitHub Secret that sets name of Storage Account where AQUA apps are"
  type        = string
}
