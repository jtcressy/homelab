output "mysql_us-central1" {
  value     = google_sql_database_instance.mysql_us-central1
  sensitive = true
}

output "kms_keyring_production_global" {
  value     = google_kms_key_ring.production.self_link
  sensitive = true
}

output "zerotier_network_id" {
  value = zerotier_network.jtcressy_net.id
}

output "zerotier_identities" {
  value = {
    home = {
      id = zerotier_identity.home.id
      private = zerotier_identity.home.private_key
      public = zerotier_identity.home.public_key
    }
  }
  sensitive = true
}