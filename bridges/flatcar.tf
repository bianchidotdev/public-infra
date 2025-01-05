# despite being recommended by flatcar, I can't get this to work
# with an ignition config - support for vultr says it's not supported
# resource "vultr_iso_private" "flatcar" {
#   url = "https://${var.flatcar_release_channel}.release.flatcar-linux.net/${var.flatcar_architecture}-usr/${var.flatcar_version}/flatcar_production_iso_image.iso"
# }

data "vultr_os" "flatcar-stable" {
  filter {
    name = "name"
    values = ["Flatcar Container Linux Stable x64"]
  }
}
