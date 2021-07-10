resource google_service_account velero {
  account_id   = "velero"
  display_name = "Velero service account"
  project      = data.google_project.current.project_id
}

resource google_service_account_iam_binding velero-ksa {
  role = "roles/iam.workloadIdentityUser"
  members = [
    "serviceAccount:${data.google_project.current.project_id}.svc.id.goog[velero/velero]"
  ]
  service_account_id = google_service_account.velero.id
}

resource google_project_iam_custom_role velero-server {
  role_id = "veleroserver"
  title   = "Velero Server"
  project = data.google_project.current.project_id
  permissions = [
    "compute.disks.get",
    "compute.disks.create",
    "compute.disks.createSnapshot",
    "compute.snapshots.get",
    "compute.snapshots.create",
    "compute.snapshots.useReadOnly",
    "compute.snapshots.delete",
    "compute.zones.get",
  ]
}

resource google_project_iam_binding velero-server {
  members = [
    "serviceAccount:${google_service_account.velero.email}"
  ]
  role = google_project_iam_custom_role.velero-server.id
}

resource google_storage_bucket_iam_binding velero-server {
  members = [
    "serviceAccount:${google_service_account.velero.email}"
  ]
  bucket = "jtcressy-net-velero-backups"
  role   = "roles/storage.objectAdmin"
}