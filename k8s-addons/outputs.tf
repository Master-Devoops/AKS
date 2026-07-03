output "ingress_public_ip" {
  description = "Point your DNS A-records (app.example.com, api.example.com) at this IP"
  value       = azurerm_public_ip.ingress.ip_address
}

output "ingress_fqdn" {
  description = "Azure-issued FQDN for the Ingress public IP - use this as your CNAME target"
  value       = azurerm_public_ip.ingress.fqdn
}

output "active_cluster_issuer" {
  value = local.active_issuer
}
