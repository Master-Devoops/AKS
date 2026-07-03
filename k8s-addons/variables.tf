variable "resource_group_name" {
  type        = string
  description = "Resource group that contains the AKS cluster (root module output)"
}

variable "aks_name" {
  type        = string
  description = "AKS cluster name (root module output)"
}

variable "ingress_namespace" {
  type    = string
  default = "ingress-nginx"
}

variable "cert_manager_namespace" {
  type    = string
  default = "cert-manager"
}

variable "app_namespace" {
  type    = string
  default = "webapp"
}

variable "letsencrypt_email" {
  description = "Email used for Let's Encrypt registration/expiry notices"
  type        = string
}

variable "app_hostname" {
  description = "Public hostname the sample app is served on, e.g. app.example.com"
  type        = string
}

variable "api_hostname" {
  description = "Public hostname the sample API is served on, e.g. api.example.com"
  type        = string
}

variable "nginx_hostname" {
  description = "Public hostname for the simple standalone NGINX app"
  type        = string
  default     = "softradix-aks.devoops.in"
}

variable "ingress_dns_label" {
  description = <<EOT
DNS label for the Ingress Public IP, must be globally unique within its
Azure region. Produces an FQDN of the form
<label>.<region>.cloudapp.azure.com - use this as your CNAME target.
EOT
  type    = string
  default = "softradix-aks"
}

variable "app_image" {
  description = "Container image for the sample web app"
  type        = string
  default     = "nginxdemos/hello:latest"
}

variable "letsencrypt_environment" {
  description = "Use 'staging' first to avoid Let's Encrypt rate limits, then switch to 'production'"
  type        = string
  default     = "staging"
}

variable "tags" {
  type    = map(string)
  default = {}
}
