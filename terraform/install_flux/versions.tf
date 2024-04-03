terraform {
  required_version = ">=1.1.5"

  required_providers {
    flux = {
      source = "fluxcd/flux"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.27.0"
    }
    github = {
      source  = "integrations/github"
      version = ">=5.18.0"
    }
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
}


provider "github" {
  owner = var.github_org
  token = var.github_token
}

# provider "flux" {
#   kubernetes = {
#     host                   = kubernetes.cluster.server
#     client_certificate     = kubernetes.cluster.client_certificate
#     client_key             = kubernetes.cluster.client_key
#     cluster_ca_certificate = kubernetes.cluster.cluster_ca_certificate
#   }
#   git = {
#     url = "ssh://git@github.com/${var.github_org}/${var.github_repository}.git"
#     ssh = {
#       username    = "git"
#       private_key = tls_private_key.flux.private_key_pem
#     }
#   }
# }