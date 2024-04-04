# Configure the OpenStack provider hosted by OVHcloud
provider "openstack" {
  auth_url    = "https://auth.cloud.ovh.net/v3/" # Authentication URL
  domain_name = "default" # Domain name - Always at 'default' for OVHcloud
  alias       = "ovh" # An alias
}

provider "ovh" {
  alias              = "ovh"
  endpoint           = "ovh-eu"
  application_key    = var.OS_APPLICATION_KEY
  application_secret = var.OS_APPLICATION_SECRET
  consumer_key       = var.OS_CONSUMER_KEY
}

provider "helm" {
  kubernetes {
    config_path = local.kube_path
  }
}

provider "kubernetes" {
  config_path = local.kube_path
}
