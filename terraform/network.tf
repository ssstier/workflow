# Create a virtual network within the resource group
resource "azurerm_virtual_network" "jenkins_vnet" {
  name                = "jenkins-vnet"
  resource_group_name = azurerm_resource_group.jenkins.name
  location            = azurerm_resource_group.jenkins.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "jenkins_subnet" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.jenkins.name
  virtual_network_name = azurerm_virtual_network.jenkins_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create a subnet for AKS
resource "azurerm_subnet" "aks_subnet" {
  name                 = "aks-subnet"
  resource_group_name  = azurerm_resource_group.jenkins.name
  virtual_network_name = azurerm_virtual_network.jenkins_vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "jenkins_master_nic" {
  name                = "jenkins-master-nic"
  location            = azurerm_resource_group.jenkins.location
  resource_group_name = azurerm_resource_group.jenkins.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.jenkins_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.jenkins_master_public_ip.id
  }
}