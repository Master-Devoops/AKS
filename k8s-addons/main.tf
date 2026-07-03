# -----------------------------------------------------------------------------
# Static Public IP for the NGINX Ingress Controller's Load Balancer Service.
# This is created in the AKS *node resource group* (MC_...) because that is
# where AKS-managed Standard Load Balancers must find their IP resources.
# This one IP is the SINGLE public entry point into the whole platform.
# -----------------------------------------------------------------------------
resource "azurerm_public_ip" "ingress" {
  name                = "${var.aks_name}-ingress-pip"
  location            = data.azurerm_kubernetes_cluster.this.location
  resource_group_name = data.azurerm_kubernetes_cluster.this.node_resource_group

  allocation_method = "Static"
  sku               = "Standard"

  # Gives this IP a stable Azure-issued hostname, e.g.
  #   softradix-aks.eastus2.cloudapp.azure.com
  # Use this as the CNAME target for your subdomain instead of pointing
  # DNS directly at the raw IP - if the IP is ever recreated for any
  # reason, the label can be re-attached and your CNAME keeps working
  # without you having to touch DNS again.
  domain_name_label = var.ingress_dns_label

  tags = var.tags
}

# -----------------------------------------------------------------------------
# NGINX Ingress Controller
# Internet -> Public IP -> Standard LB -> NGINX Ingress -> Service -> Pods
# -----------------------------------------------------------------------------
resource "helm_release" "ingress_nginx" {
  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  namespace        = var.ingress_namespace
  create_namespace = true
  version          = "4.11.3"

  set {
    name  = "controller.service.type"
    value = "LoadBalancer"
  }

  set {
    name  = "controller.service.loadBalancerIP"
    value = azurerm_public_ip.ingress.ip_address
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/azure-load-balancer-resource-group"
    value = data.azurerm_kubernetes_cluster.this.node_resource_group
  }

  set {
    name  = "controller.service.externalTrafficPolicy"
    value = "Local"
  }

  set {
    name  = "controller.replicaCount"
    value = "2"
  }

  set {
    name  = "controller.metrics.enabled"
    value = "true"
  }
}

# -----------------------------------------------------------------------------
# cert-manager - automatic TLS certificate issuance/renewal via Let's Encrypt
# -----------------------------------------------------------------------------
resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  namespace        = var.cert_manager_namespace
  create_namespace = true
  version          = "v1.15.3"

  set {
    name  = "installCRDs"
    value = "true"
  }
}

# ClusterIssuer - staging (use first, no rate limits, browser will show
# an untrusted cert - that's expected and confirms the plumbing works).
resource "kubernetes_manifest" "cluster_issuer_staging" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name = "letsencrypt-staging"
    }
    spec = {
      acme = {
        server = "https://acme-staging-v02.api.letsencrypt.org/directory"
        email  = var.letsencrypt_email
        privateKeySecretRef = {
          name = "letsencrypt-staging-key"
        }
        solvers = [
          {
            http01 = {
              ingress = {
                class = "nginx"
              }
            }
          }
        ]
      }
    }
  }

  depends_on = [helm_release.cert_manager]
}

# ClusterIssuer - production (switch Ingress annotation to this once staging
# is verified end-to-end).
resource "kubernetes_manifest" "cluster_issuer_production" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name = "letsencrypt-production"
    }
    spec = {
      acme = {
        server = "https://acme-v02.api.letsencrypt.org/directory"
        email  = var.letsencrypt_email
        privateKeySecretRef = {
          name = "letsencrypt-production-key"
        }
        solvers = [
          {
            http01 = {
              ingress = {
                class = "nginx"
              }
            }
          }
        ]
      }
    }
  }

  depends_on = [helm_release.cert_manager]
}

locals {
  active_issuer = var.letsencrypt_environment == "production" ? "letsencrypt-production" : "letsencrypt-staging"
}

# -----------------------------------------------------------------------------
# Sample application namespace
# -----------------------------------------------------------------------------
resource "kubernetes_namespace" "app" {
  metadata {
    name   = var.app_namespace
    labels = { "app.kubernetes.io/managed-by" = "terraform" }
  }
}

# -----------------------------------------------------------------------------
# Sample WEB app -> app.example.com
# -----------------------------------------------------------------------------
resource "kubernetes_deployment" "web" {
  metadata {
    name      = "web"
    namespace = kubernetes_namespace.app.metadata[0].name
    labels    = { app = "web" }
  }

  spec {
    replicas = 2

    selector {
      match_labels = { app = "web" }
    }

    template {
      metadata {
        labels = { app = "web" }
      }

      spec {
        container {
          name  = "web"
          image = var.app_image

          port {
            container_port = 80
          }

          resources {
            requests = { cpu = "50m", memory = "64Mi" }
            limits   = { cpu = "200m", memory = "128Mi" }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "web" {
  metadata {
    name      = "web"
    namespace = kubernetes_namespace.app.metadata[0].name
  }

  spec {
    selector = { app = "web" }

    port {
      port        = 80
      target_port = 80
    }

    type = "ClusterIP"
  }
}

# -----------------------------------------------------------------------------
# Sample API app -> api.example.com
# -----------------------------------------------------------------------------
resource "kubernetes_deployment" "api" {
  metadata {
    name      = "api"
    namespace = kubernetes_namespace.app.metadata[0].name
    labels    = { app = "api" }
  }

  spec {
    replicas = 2

    selector {
      match_labels = { app = "api" }
    }

    template {
      metadata {
        labels = { app = "api" }
      }

      spec {
        container {
          name  = "api"
          image = var.app_image

          port {
            container_port = 80
          }

          resources {
            requests = { cpu = "50m", memory = "64Mi" }
            limits   = { cpu = "200m", memory = "128Mi" }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "api" {
  metadata {
    name      = "api"
    namespace = kubernetes_namespace.app.metadata[0].name
  }

  spec {
    selector = { app = "api" }

    port {
      port        = 80
      target_port = 80
    }

    type = "ClusterIP"
  }
}

# -----------------------------------------------------------------------------
# Ingress - hostname-based routing, automatic TLS via cert-manager
# -----------------------------------------------------------------------------
resource "kubernetes_ingress_v1" "app" {
  metadata {
    name      = "webapp-ingress"
    namespace = kubernetes_namespace.app.metadata[0].name
    annotations = {
      "kubernetes.io/ingress.class"              = "nginx"
      "cert-manager.io/cluster-issuer"           = local.active_issuer
      "nginx.ingress.kubernetes.io/ssl-redirect" = "true"
    }
  }

  spec {
    ingress_class_name = "nginx"

    tls {
      hosts       = [var.app_hostname]
      secret_name = "web-tls"
    }

    tls {
      hosts       = [var.api_hostname]
      secret_name = "api-tls"
    }

    tls {
      hosts       = [var.nginx_hostname]
      secret_name = "nginx-simple-tls"
    }

    rule {
      host = var.app_hostname
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service.web.metadata[0].name
              port { number = 80 }
            }
          }
        }
      }
    }

    rule {
      host = var.api_hostname
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service.api.metadata[0].name
              port { number = 80 }
            }
          }
        }
      }
    }

    rule {
      host = var.nginx_hostname
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service.nginx_simple.metadata[0].name
              port { number = 80 }
            }
          }
        }
      }
    }
  }

  depends_on = [helm_release.ingress_nginx]
}

# -----------------------------------------------------------------------------
# Simple standalone NGINX app -> softradix-aks.devoops.in
# Plain nginx:stable-alpine serving a static page from a ConfigMap - nothing
# to build or push, just apply and it's live.
# -----------------------------------------------------------------------------
resource "kubernetes_config_map" "nginx_simple_html" {
  metadata {
    name      = "nginx-simple-html"
    namespace = kubernetes_namespace.app.metadata[0].name
  }

  data = {
    "index.html" = <<-HTML
      <!DOCTYPE html>
      <html lang="en">
      <head>
        <meta charset="UTF-8" />
        <title>Softradix AKS</title>
        <style>
          body { font-family: sans-serif; background:#0f172a; color:#e2e8f0;
                 display:flex; align-items:center; justify-content:center;
                 height:100vh; margin:0; }
          .card { text-align:center; padding:2rem 3rem; border-radius:12px;
                   background:#1e293b; box-shadow:0 10px 30px rgba(0,0,0,.4); }
          h1 { margin:0 0 .5rem; }
          p { color:#94a3b8; }
        </style>
      </head>
      <body>
        <div class="card">
          <h1>&#128274; Served privately, reached publicly</h1>
          <p>NGINX pod behind a private AKS cluster, exposed via Ingress + TLS.</p>
        </div>
      </body>
      </html>
    HTML
  }
}

resource "kubernetes_deployment" "nginx_simple" {
  metadata {
    name      = "nginx-simple"
    namespace = kubernetes_namespace.app.metadata[0].name
    labels    = { app = "nginx-simple" }
  }

  spec {
    replicas = 2

    selector {
      match_labels = { app = "nginx-simple" }
    }

    template {
      metadata {
        labels = { app = "nginx-simple" }
      }

      spec {
        container {
          name  = "nginx"
          image = "nginx:1.27-alpine"

          port {
            container_port = 80
          }

          resources {
            requests = { cpu = "50m", memory = "64Mi" }
            limits   = { cpu = "200m", memory = "128Mi" }
          }

          volume_mount {
            name       = "html"
            mount_path = "/usr/share/nginx/html"
          }
        }

        volume {
          name = "html"
          config_map {
            name = kubernetes_config_map.nginx_simple_html.metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "nginx_simple" {
  metadata {
    name      = "nginx-simple"
    namespace = kubernetes_namespace.app.metadata[0].name
  }

  spec {
    selector = { app = "nginx-simple" }

    port {
      port        = 80
      target_port = 80
    }

    type = "ClusterIP"
  }
}
