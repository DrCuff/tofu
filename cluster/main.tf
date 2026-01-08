terraform {
  required_providers {
    incus = {
      source = "lxc/incus"
      version = "1.0.2"
    }
  }
}

provider "incus" {
  remote {
    name    = "linuxmini"
    address = "https://192.168.1.204:8443"
    token   = "token"
  }
  generate_client_certificates = true
  accept_remote_certificate    = true
}

# Define the incus instance resource
resource "incus_instance" "headnode" {
  name     = "headnode"
  image    = "images:ubuntu/22.04" # Use a public image from the "images" remote
  running  = true                   # This ensures the container is started
  ephemeral = false                  # Set to true if you don't want it to persist after stopping
}
