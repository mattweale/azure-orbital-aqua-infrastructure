          cat <<EOT  >> ./main/backendtest
          resource_group_name  = "rg-persistent"
          storage_account_name = "samrwtfstate"
          container_name       = "tfstate" 
          key                  = "aqua.terraform.tfstate"
          EOT