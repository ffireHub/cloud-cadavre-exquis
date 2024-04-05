module "Install_instance_and_kube" {
  source = "./setup_kube"
  instance = var.instance
  OS_APPLICATION_KEY = var.OS_APPLICATION_KEY
  OS_APPLICATION_SECRET = var.OS_APPLICATION_SECRET
  OS_CONSUMER_KEY = var.OS_CONSUMER_KEY
}

module "Install_flux" {
  source = "./install_flux"
  github_token = var.GITHUB_TOKEN
  github_org = var.GITHUB_ORG
  github_repository = var.GITHUB_REPOSITORY
  kubeconfig_path = module.Install_instance_and_kube.cluster_ready_marker
}
