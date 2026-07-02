output "ingress_public_ip" {
  description = "Point your DNS A-records (app.example.com, api.example.com) at this IP"
  value       = azurerm_public_ip.ingress.ip_address
}

output "active_cluster_issuer" {
  value = local.active_issuer
}
