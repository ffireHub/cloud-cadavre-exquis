variable "OS_APPLICATION_KEY" { type = string }
variable "OS_APPLICATION_SECRET" { type = string }
variable "OS_CONSUMER_KEY" { type = string }
variable "GITHUB_TOKEN" { type = string }

variable "instance" {
  description = "List of instances"
  type = list(object({
    server_type = string
    name = string
    flavor_name = optional(string, "c3-4")
    image_id = optional(string, "13beb57f-325b-4542-811d-bdeff2a9dc29")
  }))
  default = [ {
    server_type = "controller"
    name = "controller"
    flavor_name = "c3-4"
    image_id = "13beb57f-325b-4542-811d-bdeff2a9dc29"
  }, {
    server_type = "worker"
    name = "worker1"
    flavor_name = "r3-16"
    image_id = "13beb57f-325b-4542-811d-bdeff2a9dc29"
  }, {
    server_type = "worker"
    name = "worker2"
    flavor_name = "r3-16"
    image_id = "13beb57f-325b-4542-811d-bdeff2a9dc29"
  }]
}

variable "GITHUB_ORG" {
    type = string
    default = "ffirehub"
}
variable "GITHUB_REPOSITORY" {
    type = string
    # default = "cloud-cadavre-exquis"
    default = "repo-test-for-flux"
}