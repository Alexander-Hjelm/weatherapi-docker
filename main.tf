provider "azurerm" {
    version = "2.5.0"
    features {}
}

resource "azurerm_storage_account" "tfsa_test" {
    name = "tfstorageaccountalex"
    location = azurerm_resource_group.tf_test.location
    resource_group_name = azurerm_resource_group.tf_test.name
    account_tier = "Standard"
    account_replication_type = "LRS"
    allow_blob_public_access = true
}

data "azurerm_storage_container" "tfstate" {
  name                 = "tfstate"
  storage_account_name = azurerm_storage_account.tfsa_test.name
}

terraform {
    backend "azurerm" {
        resource_group_name = azurerm_resource_group.tf_test.name
        storage_account_name = azurerm_storage_account.tfsa_test.name
        container_name = azurerm_storage_container.tfstate.name
        key = "terraform.tfstate"
    }
}

variable "imagebuild" {
  type = string
  description = "Latest image build"
}

resource "azurerm_resource_group" "tf_test" {
    name = "tfmainrg"
    location = "Norway East"
}

resource "azurerm_container_group" "tfcg_test" {
    name = "weatherapirg"
    location = azurerm_resource_group.tf_test.location
    resource_group_name = azurerm_resource_group.tf_test.name
    ip_address_type = "public"
    dns_name_label = "alexanderhjelmweatherapi"
    os_type = "linux"

    container {
      name = "weatherapi"
      image = "alexanderhjelm/weatherapi:${var.imagebuild}"
      cpu = "1"
      memory = "1"
      ports {
          port = 80
          protocol = "TCP"
      }
    }
}