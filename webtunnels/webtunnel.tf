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

resource "vultr_firewall_group" "webtunnel" {
  description = "Allow inbound traffic for webtunnels"
}

# this is a bit of a hack, but it works
# this ends up opening ports for all the bridges
# even though they only individually need their own
# port open
resource "vultr_firewall_rule" "webtunnel_allow_or_port" {
  for_each          = local.webtunnels
  firewall_group_id = vultr_firewall_group.webtunnel.id
  protocol          = "tcp"
  ip_type           = "v4"
  subnet            = "0.0.0.0"
  subnet_size       = 0
  port              = each.value.or_port
}

# butane -> ignition resource
data "ct_config" "webtunnel" {
  for_each     = local.webtunnels
  content      = file("./coreos/system.yaml")
  strict       = true
  pretty_print = false

  snippets = flatten([
    templatefile("./coreos/webtunnel.yaml.tftpl", {
      bridge_name = "${var.bridge_name_prefix}${each.key}"
      email       = var.bridge_email
      or_port     = each.value.or_port
    }),
    var.tailscale_auth_key == "" ? [] : [templatefile("./coreos/tailscale.yaml.tftpl", {
      tailscale_auth_key = var.tailscale_auth_key
    })],
    (var.logs_access_key_id == "" && var.logs_secret_access_key == "") ? [] : [
      templatefile("./coreos/logs.yaml.tftpl", {
        aws_access_key_id     = var.logs_access_key_id
        aws_secret_access_key = var.logs_secret_access_key
        host                  = "${var.bridge_name_prefix}${each.key}"
      })
    ]
  ])
}
