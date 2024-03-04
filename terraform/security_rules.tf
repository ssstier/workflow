# Create a network security group
resource "azurerm_network_security_group" "jenkins_nsg" {
  name                = "jenkins-nsg"
  location            = azurerm_resource_group.jenkins.location
  resource_group_name = azurerm_resource_group.jenkins.name
}
# Create a security rule to allow SSH
resource "azurerm_network_security_rule" "ssh" {
  name                        = "SSH"
  priority                    = 1000
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"  # You should restrict this to known IPs for better security
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.jenkins.name
  network_security_group_name = azurerm_network_security_group.jenkins_nsg.name
}
resource "azurerm_network_security_rule" "jenkins_web" {
  name                        = "JenkinsWeb"
  priority                    = 1010
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "8080"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.jenkins.name
  network_security_group_name = azurerm_network_security_group.jenkins_nsg.name
}

resource "azurerm_network_security_rule" "jenkins_agent" {
  name                        = "JenkinsAgent"
  priority                    = 1020
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "50000"
  source_address_prefix       = "*"  # Consider restricting to specific IPs for security
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.jenkins.name
  network_security_group_name = azurerm_network_security_group.jenkins_nsg.name
}

# Associate the network security group with the network interface
resource "azurerm_network_interface_security_group_association" "jenkins_nic_nsg_association" {
  network_interface_id      = azurerm_network_interface.jenkins_master_nic.id
  network_security_group_id = azurerm_network_security_group.jenkins_nsg.id
}