resource google_compute_global_address mysql_us-central1 {
  name          = "mysql-private-ip"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = data.google_compute_network.default_us-central1.self_link
}

resource google_service_networking_connection mysql_us-central1 {
  network                 = data.google_compute_network.default_us-central1.self_link
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.mysql_us-central1.name]
}

resource random_id mysql_us-central1_name-suffix {
  byte_length = 4
}

resource google_sql_database_instance mysql_us-central1 {
  name   = "mysql-private-instance-${random_id.mysql_us-central1_name-suffix.hex}"
  region = "us-central1"

  depends_on = [google_service_networking_connection.mysql_us-central1]

  database_version = "MYSQL_5_7"
  settings {
    tier = "db-f1-micro"
    ip_configuration {
      ipv4_enabled    = false
      private_network = data.google_compute_network.default_us-central1.self_link
    }
    disk_autoresize = true
    disk_size       = 10
    backup_configuration {
      enabled    = true
      start_time = "08:00"
    }
  }
}