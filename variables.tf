variable "gcp_project_id" {
  description = "GCP Project ID for Atlas PoC"
  type        = string
}

variable "gcp_region" {
  description = "GCP Region"
  type        = string
  default     = "us-central1"
}

variable "deployment_id" { // <--- CHANGE TO THIS
  description = "Unique identifier for this specific PoC deployment (e.g., atlas-test01)"
  type        = string
}

variable "instance_machine_type" {
  description = "GCE machine type"
  type        = string
  default     = "e2-micro"
}