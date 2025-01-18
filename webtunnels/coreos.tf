data "vultr_os" "coreos-stable" {
  filter {
    name   = "name"
    values = ["Fedora CoreOS Stable"]
  }
}
