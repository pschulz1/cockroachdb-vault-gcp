terraform {
  required_providers {
    hcp = {
      source  = "hashicorp/hcp"
      version = "~> 0.20.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 4.2.1"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "~> 3.0.1"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  #Assumes auth via gloud "gcloud auth application-default login"
}

provider "vault" {
  # It is strongly recommended to configure this provider through the
  # environment variables described above, so that each user can have
  # separate credentials set in the environment.
  #
  # This will default to using $VAULT_ADDR and $VAUT_TOKEN
  # But can be set explicitly
  namespace = "admin"
}

