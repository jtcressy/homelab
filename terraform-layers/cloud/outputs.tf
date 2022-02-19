# output "mysql_us-central1" {
#   value     = google_sql_database_instance.mysql_us-central1
#   sensitive = true
# }

output "kms_keyring_production_global" {
  value     = google_kms_key_ring.production.id
  sensitive = true
}
