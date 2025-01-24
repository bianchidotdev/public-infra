resource "vultr_instance" "webtunnel" {
  for_each = local.webtunnels
  # high performance amd 1vcpu 1gb ram
  plan     = "vhp-1c-1gb-amd"
  region   = each.value.region
  os_id    = data.vultr_os.coreos-stable.id
  label    = each.key
  hostname = "${var.bridge_name_prefix}${each.key}"

  firewall_group_id = vultr_firewall_group.webtunnel.id

  user_data = data.ct_config.webtunnel[each.key].rendered

  lifecycle {
    ignore_changes = [
      user_data,
    ]
  }

  tags = [
    "bridge",
    "terraform",
    "webtunnel",
  ]
}

output "webtunnels" {
  sensitive = true
  value     = vultr_instance.webtunnel
}

resource "vultr_firewall_group" "webtunnel" {
  description = "Allow inbound traffic for webtunnels"
}

resource "vultr_firewall_rule" "webtunnel_http" {
  firewall_group_id = vultr_firewall_group.webtunnel.id
  protocol          = "tcp"
  ip_type           = "v4"
  subnet            = "0.0.0.0"
  subnet_size       = 0
  port              = 80
}

resource "vultr_firewall_rule" "webtunnel_https" {
  firewall_group_id = vultr_firewall_group.webtunnel.id
  protocol          = "tcp"
  ip_type           = "v4"
  subnet            = "0.0.0.0"
  subnet_size       = 0
  port              = 443
}

resource "vultr_firewall_rule" "webtunnel_ipv6_http" {
  firewall_group_id = vultr_firewall_group.webtunnel.id
  protocol          = "tcp"
  ip_type           = "v6"
  subnet            = "::"
  subnet_size       = 0
  port              = 80
}

resource "vultr_firewall_rule" "webtunnel_ipv6_https" {
  firewall_group_id = vultr_firewall_group.webtunnel.id
  protocol          = "tcp"
  ip_type           = "v6"
  subnet            = "::"
  subnet_size       = 0
  port              = 443
}

resource "porkbun_dns_record" "webtunnel" {
  for_each = local.webtunnels

  name    = each.value.subdomain
  domain  = var.webtunnel_domain
  type    = "A"
  content = vultr_instance.webtunnel[each.key].main_ip
}

# butane -> ignition resource
data "ct_config" "webtunnel" {
  for_each = local.webtunnels
  content = templatefile("../coreos/system.yaml.tftpl", {
    tailscale_rpm = var.tailscale_auth_key == "" ? "" : "tailscale"
    caddy_rpm     = "caddy"
  })
  strict       = true
  pretty_print = false

  snippets = flatten([
    templatefile("../coreos/webtunnel.yaml.tftpl", {
      bridge_name      = "${var.bridge_name_prefix}${each.key}"
      email            = var.bridge_email
      webtunnel_domain = "${each.value.subdomain}.${var.webtunnel_domain}"
      webtunnel_path   = each.value.random_path
    }),
    var.tailscale_auth_key == "" ? [] : [templatefile("../coreos/tailscale.yaml.tftpl", {
      tailscale_auth_key = var.tailscale_auth_key
    })],
    (var.logs_access_key_id == "" && var.logs_secret_access_key == "") ? [] : [
      templatefile("../coreos/logs.yaml.tftpl", {
        aws_access_key_id     = var.logs_access_key_id
        aws_secret_access_key = var.logs_secret_access_key
        host                  = "${var.bridge_name_prefix}${each.key}"
      })
    ]
  ])
}
