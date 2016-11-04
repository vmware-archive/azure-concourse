///////////======================//////////////
//// Firewall Rule(s) ===========//////////////
///////////======================//////////////

//// Create Firewall Rule for allow-ssh from public
resource "google_compute_firewall" "allow-ssh" {
  name    = "${var.gcp_terraform_prefix}-allow-ssh"
  network = "${google_compute_network.pcf-virt-net.name}"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags = ["allow-ssh"]
}

//// Create Firewall Rule for allow-http from public
resource "google_compute_firewall" "pcf-allow-http" {
  name    = "${var.gcp_terraform_prefix}-allow-http"
  network = "${google_compute_network.pcf-virt-net.name}"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags = ["allow-http","router"]
}

//// Create Firewall Rule to allow GO ROuter Health Checks
resource "google_compute_firewall" "pcf-allow-http-8080" {
  name    = "${var.gcp_terraform_prefix}-allow-http-8080"
  network = "${google_compute_network.pcf-virt-net.name}"

  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags = ["router"]
}


//// Create Firewall Rule for allow-https from public
resource "google_compute_firewall" "pcf-allow-https" {
  name    = "${var.gcp_terraform_prefix}-allow-https"
  network = "${google_compute_network.pcf-virt-net.name}"

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags = ["allow-https","router"]
}


//// Create Firewall Rule for allow-ert-all com between bosh deployed ert jobs
//// This will match the default OpsMan tag configured for the deployment
resource "google_compute_firewall" "allow-ert-all" {
  name    = "${var.gcp_terraform_prefix}-allow-ert-all"
  depends_on = ["google_compute_network.pcf-virt-net"]
  network = "${google_compute_network.pcf-virt-net.name}"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
  }

  allow {
    protocol = "udp"
  }
  target_tags = ["${var.gcp_terraform_prefix}","${var.gcp_terraform_prefix}-opsman","nat-traverse"]
  source_tags = ["${var.gcp_terraform_prefix}","${var.gcp_terraform_prefix}-opsman","nat-traverse"]
}

//// Allow access to ssh-proxy [Optional]
resource "google_compute_firewall" "cf-ssh-proxy" {
  name       = "${var.gcp_terraform_prefix}-allow-ssh-proxy"
  depends_on = ["google_compute_network.pcf-virt-net"]
  network    = "${google_compute_network.pcf-virt-net.name}"

  allow {
    protocol = "tcp"
    ports    = ["2222"]
  }

  target_tags = ["${var.gcp_terraform_prefix}-ssh-proxy","diego-brain"]
}



//// Allow access to Optional CF TCP router
resource "google_compute_firewall" "cf-tcp" {
  name       = "${var.gcp_terraform_prefix}-allow-cf-tcp"
  depends_on = ["google_compute_network.pcf-virt-net"]
  network    = "${google_compute_network.pcf-virt-net.name}"

  allow {
    protocol = "tcp"
    ports    = ["1024-65535"]
  }

  target_tags = ["${var.gcp_terraform_prefix}-cf-tcp"]
}
