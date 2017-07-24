# Configure the Google Cloud provider
provider "google" {
  credentials = "${file("~/.gcp/probcomp.json")}"
  project     = "${var.google_project}"
  region      = "${var.region}"
}

provider "kubernetes" {
  username = "${var.cluster_master_username}"
  password = "${var.cluster_master_password}"
}

# Enable APIs for project so terraform can do it's thing
resource "google_project_services" "probcomp" {
  project = "${var.google_project}"

  services = [
    "iam.googleapis.com",
    "compute-component.googleapis.com",
    "container.googleapis.com",
    "servicemanagement.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "storage-api.googleapis.com",
    "dns.googleapis.com"
  ]
}

resource "google_compute_network" "private" {
  name                    = "private"
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "private" {
  name          = "${var.prefix}-private-subnet"
  ip_cidr_range = "10.1.0.0/16"
  network       = "${google_compute_network.private.self_link}"
  region        = "${var.region}"
}

resource "google_container_cluster" "probcomp" {
  name               = "${var.prefix}-cluster"
  zone               = "us-east1-b"
  initial_node_count = "1"
  network            = "${google_compute_network.private.name}"
  subnetwork         = "${google_compute_subnetwork.private.name}"

  node_config {
    machine_type = "n1-standard-1"

    oauth_scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/service.management"
    ]
  }

  monitoring_service = "monitoring.googleapis.com"

  master_auth {
    username = "${var.cluster_master_username}"
    password = "${var.cluster_master_password}"
  }
}
