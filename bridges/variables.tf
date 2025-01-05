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

variable "tailscale_auth_key" {
  default   = ""
  sensitive = true
  type      = string
}
