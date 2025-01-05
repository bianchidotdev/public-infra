terraform {
  required_providers {
    vultr = {
      source  = "vultr/vultr"
      version = "2.23.1"
    }

    ct = {
      source  = "poseidon/ct"
      version = "0.13.0"
    }
  }

  backend "s3" {
    bucket                      = "homelab-tf-state"
    key                         = "vultr/terraform.tfstate"
    region                      = "global"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
    endpoints                   = { s3 = "https://fly.storage.tigris.dev" }
  }
}

provider "vultr" {
  rate_limit  = 100
  retry_limit = 3
}

provider "ct" {}
