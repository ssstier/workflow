terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.86.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
  # Configuration options
}

# Create a resource group
resource "azurerm_resource_group" "jenkins" {
  name     = "jenkins-resources"
  location = "East US"
}