resource "google_service_account" "csi-gcs" {
  account_id = "csi-gcs"
}

resource "google_project_iam_member" "csi-gcs_admin" {
  project = data.google_project.current.project_id
  member  = "serviceAccount:${google_service_account.csi-gcs.email}"
  role    = "roles/storage.admin"
}

resource "google_project_iam_member" "csi-gcs_objectAdmin" {
  project = data.google_project.current.project_id
  member  = "serviceAccount:${google_service_account.csi-gcs.email}"
  role    = "roles/storage.objectAdmin"
}

resource "google_service_account_key" "csi-gcs" {
  service_account_id = google_service_account.csi-gcs.id
}
