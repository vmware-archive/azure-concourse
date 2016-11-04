///////////////////////////////////////////////
//////  Create Pivotal Opsman  ////////////////
///////////////////////////////////////////////

resource "google_compute_instance" "ops-manager" {
  name         = "${var.gcp_terraform_prefix}-ops-manager"
  depends_on   = ["google_compute_subnetwork.subnet-ops-manager"]
  machine_type = "n1-standard-2"
  zone         = "${var.gcp_zone_1}"

  tags = ["${var.gcp_terraform_prefix}-opsman", "allow-https"]

  disk {
    image = "${var.pcf_opsman_image_name}"
    size  = 50
  }

  network_interface {
    subnetwork = "${google_compute_subnetwork.subnet-ops-manager.name}"

    access_config {
      # Empty for ephemeral external IP allocation
    }
  }
}

resource "google_storage_bucket" "director" {
  name          = "${var.gcp_terraform_prefix}-director"
  force_destroy = true
}
