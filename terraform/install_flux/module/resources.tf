resource "kind_cluster" "this" {
  name = "flux-e2e"
}

resource "tls_private_key" "flux" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

resource "github_repository" "this" {
  name       = var.github_repository
#   visibility = var.repository_visibility
}

resource "github_branch_default" "this" {
  repository = github_repository.this.name
  branch     = "master"
}

resource "github_repository_deploy_key" "this" {
  title      = "Flux"
  repository = github_repository.this.name
  key        = tls_private_key.flux.public_key_openssh
  read_only  = "false"
}

resource "flux_bootstrap_git" "this" {
  depends_on = [github_repository_deploy_key.this]
  path = "clusters/flux-e2e"
}

// terraform apply -var "github_org=<username or org>" -var "github_token=<token>" -var "github_repository=fleet-infra"