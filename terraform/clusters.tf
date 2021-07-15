# module gke_primary_us-central1 {
#   source = "./modules/standard-gke-cluster"
#   name = "primary"
#   location = "us-central1"
#   csi-gcs-private-key = google_service_account_key.csi-gcs.private_key
#   kms_key_id = google_kms_crypto_key.etcd_us-central1.id
#   external_dns = {
#     cf_api_token = ""
#     cf_api_email = ""
#     cf_api_key   = ""
#     proxy        = true
#     domain_filter = [
#       "jtcressy.net",
#       "joelcressy.dev"
#     ]
#   }
#   # ingress_source_ranges = data.cloudflare_ip_ranges.current.ipv4_cidr_blocks
#   ingress_source_ranges = []
#   velero_service_account = google_service_account.velero.email
# }

resource "google_container_cluster" "primary" {
  provider       = google-beta
  name           = "primary"
  location       = data.google_compute_zones.current.names[0]
  node_locations = slice(data.google_compute_zones.current.names, 1, 3)

  resource_labels = {
    "goog-gameservices" = ""
  }

  remove_default_node_pool = true
  initial_node_count       = 1

  master_auth {
    username = ""
    password = ""

    client_certificate_config {
      issue_client_certificate = false
    }
  }

  ip_allocation_policy {}

  addons_config {
    horizontal_pod_autoscaling {
      disabled = true
    }
    http_load_balancing {
      disabled = true
    }
  }

  database_encryption {
    state    = "ENCRYPTED"
    key_name = google_kms_crypto_key.etcd_us-central1.id
  }

  maintenance_policy {
    daily_maintenance_window {
      start_time = "09:00"
    }
  }

  workload_identity_config {
    identity_namespace = "${data.google_project.current.project_id}.svc.id.goog"
  }

  release_channel {
    channel = "RAPID"
  }
}

resource "google_container_node_pool" "primary_core-system" {
  provider       = google-beta
  cluster        = google_container_cluster.primary.name
  name_prefix    = "core-system"
  node_count     = 1
  location       = google_container_cluster.primary.location
  node_locations = slice(data.google_compute_zones.current.names, 0, 3)
  node_config {
    preemptible  = true
    machine_type = "e2-small"
    disk_size_gb = 20
    workload_metadata_config {
      node_metadata = "GKE_METADATA_SERVER"
    }
    tags = []
    kubelet_config {
      cpu_cfs_quota = false
    }
    oauth_scopes = [
      "storage-ro",
      "logging-write",
      "monitoring"
    ]
  }
  upgrade_settings {
    max_surge       = 0
    max_unavailable = 1
  }
  management {
    auto_repair  = true
    auto_upgrade = true
  }
  lifecycle {
    create_before_destroy = true
  }
}