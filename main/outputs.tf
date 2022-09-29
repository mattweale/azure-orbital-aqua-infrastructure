#   Outputs
output "rg_name" {
  value       = local.rg_name
  description = "The Resource Group name"
}

output "bastion_name" {
  value       = local.bastion_name
  description = "Name of the Bastion host"
}

output "data_collection_vm_id" {
  value       = local.data_collection_vm_id
  description = "Resource ID of the Data Collection VM"
}
