resource_group_name = "Softradix-AKS-RG"
aks_name             = "softradix-aks-cluster"

letsencrypt_email = "you@example.com"

app_hostname = "app.example.com"
api_hostname = "api.example.com"

nginx_hostname    = "softradix-aks.devoops.in"
ingress_dns_label = "softradix-aks"  # must be globally unique in your Azure region

# Use "staging" until you've confirmed HTTP-01 challenges + DNS work,
# then switch to "production" and re-apply.
letsencrypt_environment = "staging"

app_image = "nginxdemos/hello:latest"

tags = {
  Environment = "Production"
  Owner       = "Yogesh"
  Project     = "Terraform"
}
