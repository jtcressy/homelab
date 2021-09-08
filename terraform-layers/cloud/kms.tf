resource "google_kms_key_ring" "production" {
  name     = "production-keyring"
  location = "global"
  lifecycle {
    prevent_destroy = true # DON'T FUCKING TOUCH THIS
  }
}

resource "google_kms_key_ring_iam_binding" "gke" {
  key_ring_id = google_kms_key_ring.production.id
  role        = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  members = [
    "serviceAccount:service-${data.google_project.current.number}@container-engine-robot.iam.gserviceaccount.com"
  ]
}

resource "google_kms_crypto_key" "etcd" {
  name            = "etcd"
  key_ring        = google_kms_key_ring.production.id
  rotation_period = "7776000s"
  purpose         = "ENCRYPT_DECRYPT"
  lifecycle {
    prevent_destroy = true
  }
}


## Regional Keyrings
resource "google_kms_key_ring" "production_us-central1" {
  name     = "production-keyring"
  location = "us-central1"
  lifecycle {
    prevent_destroy = true # DON'T FUCKING TOUCH THIS
  }
}

resource "google_kms_key_ring_iam_binding" "gke_us-central1" {
  key_ring_id = google_kms_key_ring.production_us-central1.id
  role        = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  members = [
    "serviceAccount:service-${data.google_project.current.number}@container-engine-robot.iam.gserviceaccount.com"
  ]
}

resource "google_kms_crypto_key" "etcd_us-central1" {
  name            = "etcd"
  key_ring        = google_kms_key_ring.production_us-central1.id
  rotation_period = "7776000s"
  purpose         = "ENCRYPT_DECRYPT"
  lifecycle {
    prevent_destroy = true
  }
}