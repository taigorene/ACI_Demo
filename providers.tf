terraform {
  required_providers {
    aci = {
      source = "CiscoDevNet/aci"
    }
  }
}

provider "aci" {
  username = var.user.username
  password = var.user.password
  url      = var.user.url
  insecure = true
}
