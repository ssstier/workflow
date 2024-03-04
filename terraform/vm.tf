# Create a public IP address
resource "azurerm_public_ip" "jenkins_master_public_ip" {
  name                = "jenkins-master-public-ip"
  location            = azurerm_resource_group.jenkins.location
  resource_group_name = azurerm_resource_group.jenkins.name
  allocation_method   = "Dynamic"
}

data "azurerm_public_ip" "jenkins_master_ip" {
  name                = azurerm_public_ip.jenkins_master_public_ip.name
  resource_group_name = azurerm_linux_virtual_machine.jenkins_master_vm.resource_group_name
  depends_on          = [azurerm_linux_virtual_machine.jenkins_master_vm]
}

resource "azurerm_linux_virtual_machine" "jenkins_master_vm" {
  name                = "jenkins-master-vm"
  resource_group_name = azurerm_resource_group.jenkins.name
  location            = azurerm_resource_group.jenkins.location
  size                = "Standard_A1_v2"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.jenkins_master_nic.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

resource "azurerm_virtual_machine_extension" "setup" {
  name                 = "setupDockerAndJenkins"
  virtual_machine_id   = azurerm_linux_virtual_machine.jenkins_master_vm.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  settings = jsonencode({
    commandToExecute = <<-EOT
      sudo apt-get update && \
      sudo apt-get install -y ca-certificates curl gnupg lsb-release && \
      sudo install -m 0755 -d /etc/apt/keyrings && \
      curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
      sudo chmod a+r /etc/apt/keyrings/docker.gpg && \
      echo deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null && \
      sudo apt-get update && \
      sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin && \
      sudo docker run -d -p 8080:8080 -p 50000:50000 --restart=always --name=jenkins-master -v jenkins-data:/var/jenkins_home jenkins/jenkins:lts
      curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash && \
      sudo az aks install-cli --client-version 1.27.7
    EOT
  })
}