resource "azurerm_kubernetes_cluster" "devtest_aks" {
  name                = "devtest-aks"
  location            = azurerm_resource_group.jenkins.location
  resource_group_name = azurerm_resource_group.jenkins.name
  dns_prefix          = "devtest-aks-dns"
  kubernetes_version  = "1.27.7"
  private_cluster_enabled = true

  default_node_pool {
    name                = "default"
    vm_size             = "Standard_DS2_v2"
    enable_auto_scaling = true
    min_count           = 1
    max_count           = 3
    type                = "VirtualMachineScaleSets"
    vnet_subnet_id      = azurerm_subnet.aks_subnet.id
  }

  identity {
    type          = "SystemAssigned"
  }

  network_profile {
    network_plugin     = "kubenet"
    service_cidr       = "10.0.3.0/24"
    dns_service_ip     = "10.0.3.10"
    network_policy     = "calico"
    load_balancer_sku  = "standard"
    outbound_type      = "loadBalancer"
  }

  tags = {
    Environment = "Development"
  }
}