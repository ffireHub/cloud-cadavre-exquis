variable "name" {
  description = "Cadavre exquis"
  default     = "cadavre-exquis"
  type = string
}

variable "instance" {}

variable "OS_APPLICATION_KEY" {type = string}
variable "OS_APPLICATION_SECRET" {type = string}
variable "OS_CONSUMER_KEY" {type = string}

variable "ssh_public_keys" {
  description = "List of SSH public keys"
  type        = list(string)
  default     = [""]
}
