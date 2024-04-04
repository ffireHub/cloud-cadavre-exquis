resource "tls_private_key" "flux" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}
resource "github_repository_deploy_key" "this" {
  title      = "Flux"
  repository = var.github_repository
  key        = tls_private_key.flux.public_key_openssh
  read_only  = "false"
}


resource "flux_bootstrap_git" "this" {
  depends_on = [github_repository_deploy_key.this]

  path = "./release"
}

resource "kubectl_manifest" "create_helmRepo" {
  depends_on = [ flux_bootstrap_git.this ]
  yaml_body  = file("${path.module}/../../release/helmRepo.yaml")
}

resource "kubectl_manifest" "create_helmRelease" {
  depends_on = [ kubectl_manifest.create_helmRepo ]
  yaml_body  = file("${path.module}/../../release/helmRelease.yaml")
}