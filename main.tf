terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

resource "google_storage_bucket" "deployment_bucket" {
  name          = "${var.deployment_id}-atlas-poc-bucket" // Updated naming
  location      = var.gcp_region
  force_destroy = true
  uniform_bucket_level_access = true // <--- ADD THIS LINE

}

resource "google_compute_instance" "deployment_vm" {
  name         = "${var.deployment_id}-atlas-poc-vm" // Updated naming
  machine_type = var.instance_machine_type
  zone         = "${var.gcp_region}-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  metadata_startup_script = "sudo apt-get update && sudo apt-get install -yq nginx && echo 'Hello from Atlas Project PoC VM for ${var.deployment_id}' > /var/www/html/index.html"

  tags = ["atlas-poc-vm", var.deployment_id]
}

resource "google_compute_firewall" "allow_http_atlas_poc" {
  name    = "${var.deployment_id}-allow-http" // Dynamic name for the firewall rule
  network = "default" // Assuming you're using the default VPC network

  allow {
    protocol = "tcp"
    ports    = ["80"] // Allow HTTP
  }

  target_tags   = ["atlas-poc-vm"] // Apply this rule to VMs with this tag
  source_ranges = ["0.0.0.0/0"]    // Allow traffic from any IP address
                                   // For production, you might restrict this further
}
output "bucket_name" {
  value = google_storage_bucket.deployment_bucket.name
}

output "vm_public_ip" {
  value = google_compute_instance.deployment_vm.network_interface[0].access_config[0].nat_ip
}

output "vm_name" {
  value = google_compute_instance.deployment_vm.name
}