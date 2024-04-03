module "flux" {
  source  = "./module"
  github_repository = var.github_repository
  github_org = var.github_org
  github_token = var.github_token
}