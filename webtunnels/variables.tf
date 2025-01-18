locals {
  webtunnel_regions = [
    "fra",
    "waw",
    "sto",
    "nrt",
    "jnb",
  ]
  # there's some hacky stuff to get around the fact that you can't iterate over sensitive data
  # and to make sure we generate the unique numbers without limiting ourselves to a `set` of
  # regions (we might want more than one webtunnel in a region)
  webtunnel_indexes = toset([for idx, _ in local.webtunnel_regions : tostring(idx)])
  webtunnels = { for idx, region in local.webtunnel_regions : "webtunnel${idx}" => {
    region  = region
    or_port = random_integer.webtunnel_or_ports[idx].result
    }
  }
}

output "webtunnels" {
  value = local.webtunnels
}

resource "random_integer" "webtunnel_or_ports" {
  for_each = local.webtunnel_indexes
  min      = 40000
  max      = 49999
}

variable "bridges" {
  type = map(object({
    region = string
  }))

  default = {
    bridge1 = {
      region = "fra" # frankfurt
    },
    bridge2 = {
      region = "waw" # warsaw
    },
    bridge3 = {
      region = "sto" # stockholm
    },
    bridge4 = {
      region = "nrt" # tokyo
    },
    bridge5 = {
      region = "jnb" # johannesburg
    },
  }
}

variable "bridge_name_prefix" {
  sensitive = true
  type      = string
}

variable "bridge_email" {
  sensitive = true
  type      = string
}

variable "bridge_or_port" {
  type    = number
  default = 12800
}

variable "bridge_pt_port" {
  type    = number
  default = 12801
}

variable "webtunnel_or_ports" {
  type      = string
  sensitive = true
}

variable "tailscale_auth_key" {
  default   = ""
  sensitive = true
  type      = string
}

variable "logs_access_key_id" {
  default   = ""
  sensitive = true
  type      = string
}

variable "logs_secret_access_key" {
  default   = ""
  sensitive = true
  type      = string
}
