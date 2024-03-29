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
  provider              = google-beta
  name                  = "primary"
  location              = data.google_compute_zones.current.names[0]
  node_locations        = slice(data.google_compute_zones.current.names, 1, 3)
  enable_shielded_nodes = false
  min_master_version    = "1.22.7"
  resource_labels = {
    "goog-gameservices" = ""
  }

  cluster_autoscaling {
    enabled = true
    autoscaling_profile = "OPTIMIZE_UTILIZATION"
    resource_limits {
      resource_type = "cpu"
      maximum = "32"
    }
    resource_limits {
      resource_type = "memory"
      maximum = "128"
    }
    auto_provisioning_defaults {
      image_type = "COS_CONTAINERD"
    }
  }

  remove_default_node_pool = true
  initial_node_count       = 1

  master_auth {
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
    config_connector_config {
      enabled = true
    }
    gce_persistent_disk_csi_driver_config {
      enabled = true
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
    workload_pool = "${data.google_project.current.project_id}.svc.id.goog"
  }

  release_channel {
    channel = "RAPID"
  }
}

resource "google_container_node_pool" "primary_core-system" {
  provider    = google-beta
  cluster     = google_container_cluster.primary.name
  for_each    = toset(slice(data.google_compute_zones.current.names, 0, 3))
  name_prefix = "core-system-${substr(each.key, -1, 0)}-"
  autoscaling {
    min_node_count = 1
    max_node_count = 3
  }
  location       = google_container_cluster.primary.location
  node_locations = [each.key]
  node_config {
    preemptible  = true
    machine_type = "n2d-standard-2"
    disk_size_gb = 20
    workload_metadata_config {
      mode = "GKE_METADATA"
    }
    tags       = []
    image_type = "COS_CONTAINERD"
    kubelet_config {
      cpu_manager_policy = "static"
      cpu_cfs_quota      = false
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