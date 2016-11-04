resource "google_storage_bucket" "buildpacks" {
  name          = "${var.gcp_terraform_prefix}-buildpacks"
  force_destroy = true
}

resource "google_storage_bucket" "droplets" {
  name          = "${var.gcp_terraform_prefix}-droplets"
  force_destroy = true
}

resource "google_storage_bucket" "packages" {
  name          = "${var.gcp_terraform_prefix}-packages"
  force_destroy = true
}

resource "google_storage_bucket" "resources" {
  name          = "${var.gcp_terraform_prefix}-resources"
  force_destroy = true
}
