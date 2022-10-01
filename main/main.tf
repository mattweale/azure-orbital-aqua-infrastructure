terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.18.0"
    }
    null = {
      version = "~> 3.1.1"
    }
  }

  required_version = ">= 1.3.0"
  backend "azurerm" {
    resource_group_name  = "rg-persistent"
    storage_account_name = "samrwtfstate"
    container_name       = "tfstate"
    key                  = "aqua.terraform.tfstate"
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy       = false
      purge_soft_deleted_keys_on_destroy = false
    }
  }
}
