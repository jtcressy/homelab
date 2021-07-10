resource google_container_cluster cluster {
  provider       = google-beta
  name           = var.name
  location       = data.google_compute_zones.current.names[0]
  node_locations = slice(data.google_compute_zones.current.names, 1, 3)

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
    key_name = var.kms_key_id
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