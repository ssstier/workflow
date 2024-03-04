output "jenkins_master_url" {
  value = "http://${data.azurerm_public_ip.jenkins_master_ip.ip_address}:8080"
  description = "The URL to access the Jenkins master web interface."
}
