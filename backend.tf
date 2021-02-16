terraform {
  backend "remote" {
    organization = "cloudlife"

    workspaces {
      name = "dev-cloudlife"
    }
  }
}