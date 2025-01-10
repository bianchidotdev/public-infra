resource "vultr_instance" "bridges" {
  for_each = var.bridges
  # high performance amd 1vcpu 1gb ram
  plan = "vhp-1c-1gb-amd"
  # frankfurt region
  region   = each.value.region
  os_id    = data.vultr_os.flatcar-stable.id
  label    = each.key
  hostname = "${var.bridge_name_prefix}${each.key}"

  firewall_group_id = vultr_firewall_group.bridges.id

  user_data = data.ct_config.bridges[each.key].rendered

  lifecycle {
    ignore_changes = [
      user_data,
    ]
  }

  tags = [
    "bridge",
    "terraform",
  ]
}

resource "vultr_firewall_group" "bridges" {
  description = "Allow inbound traffic for bridges"
}

resource "vultr_firewall_rule" "allow_or_port" {
  firewall_group_id = vultr_firewall_group.bridges.id
  protocol          = "tcp"
  ip_type           = "v4"
  subnet            = "0.0.0.0"
  subnet_size       = 0
  port              = var.bridge_or_port
}

resource "vultr_firewall_rule" "allow_pt_port" {
  firewall_group_id = vultr_firewall_group.bridges.id
  protocol          = "tcp"
  ip_type           = "v4"
  subnet            = "0.0.0.0"
  subnet_size       = 0
  port              = var.bridge_pt_port
}

# butane -> ignition resource
data "ct_config" "bridges" {
  for_each     = var.bridges
  content      = file("./system.yaml")
  strict       = true
  pretty_print = false

  snippets = flatten([
    templatefile("./bridge.yaml.tftpl", {
      bridge_name = "${var.bridge_name_prefix}${each.key}"
      email       = var.bridge_email
      or_port     = var.bridge_or_port
      pt_port     = var.bridge_pt_port
    }),
    var.tailscale_auth_key == "" ? [] : [templatefile("./tailscale.yaml.tftpl", {
      tailscale_auth_key = var.tailscale_auth_key
    })],
    (var.logs_access_key_id == "" && var.logs_secret_access_key == "") ? [] : [
      templatefile("./logs.yaml.tftpl", {
        aws_access_key_id     = var.logs_access_key_id
        aws_secret_access_key = var.logs_secret_access_key
        host                  = "${var.bridge_name_prefix}${each.key}"
      })
    ]
  ])
}
