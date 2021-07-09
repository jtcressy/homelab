resource google_container_node_pool core-system {
  provider       = google-beta
  cluster        = google_container_cluster.cluster.name
  name_prefix    = "core-system"
  node_count     = 1
  location       = google_container_cluster.cluster.location
  node_locations = slice(data.google_compute_zones.current.names, 0, 3)
  node_config {
    preemptible  = true
    machine_type = "e2-small"
    disk_size_gb = 20
    workload_metadata_config {
      node_metadata = "GKE_METADATA_SERVER"
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