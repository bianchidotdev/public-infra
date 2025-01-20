locals {
  # webtunnel_regions = [
  #   "fra",
  #   "waw",
  #   "sto",
  #   "nrt",
  #   "jnb",
  # ]
  webtunnel_data = {
    1 = {
      region    = "fra"
      subdomain = ""
    }
    # 2 = {
    #   region    = "waw"
    #   subdomain = "waw."
    # }
    # 3 = {
    #   region    = "sto"
    #   subdomain = "sto."
    # }
    # 4 = {
    #   region    = "nrt"
    #   subdomain = "nrt."
    # }
    # 5 = {
    #   region    = "jnb"
    #   subdomain = "jnb."
    # }
  }
  # there's some hacky stuff to get around the fact that you can't iterate over sensitive data
  # and to make sure we generate the unique numbers without limiting ourselves to a `set` of
  # regions (we might want more than one webtunnel in a region)
  # webtunnel_indexes = toset([for idx, _ in local.webtunnel_regions : tostring(idx)])
  webtunnels = { for idx, data in local.webtunnel_data : "webtunnel${idx}" =>
    {
      region      = data.region
      random_path = random_string.webtunnel_paths[idx].result
      subdomain   = data.subdomain
    }
  }
}

output "webtunnels" {
  value = local.webtunnels
}

resource "random_string" "webtunnel_paths" {
  for_each = local.webtunnel_data
  length   = 24
  special  = false
}

variable "bridge_name_prefix" {
  sensitive = true
  type      = string
}

variable "webtunnel_domain" {
  sensitive = true
  type      = string
}

variable "bridge_email" {
  sensitive = true
  type      = string
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
