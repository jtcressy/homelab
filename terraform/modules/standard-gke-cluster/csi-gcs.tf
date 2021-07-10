resource kubernetes_secret csi-gcs-creds {
  metadata {
    name      = "csi-gcs-creds"
    namespace = "default"
  }
  data = {
    key = base64decode(var.csi-gcs-private-key)
  }
}

resource kubernetes_storage_class csi-gcs {
  metadata {
    name = "csi-gcs"
  }
  storage_provisioner    = "gcs.csi.ofek.dev"
  reclaim_policy         = "Retain"
  volume_binding_mode    = "Immediate"
  allow_volume_expansion = false
  parameters = {
    "gcs.csi.ofek.dev/project-id"                      = data.google_project.current.project_id
    "csi.storage.k8s.io/provisioner-secret-name"       = kubernetes_secret.csi-gcs-creds.metadata.0.name
    "csi.storage.k8s.io/provisioner-secret-namespace"  = kubernetes_secret.csi-gcs-creds.metadata.0.namespace
    "csi.storage.k8s.io/node-publish-secret-name"      = kubernetes_secret.csi-gcs-creds.metadata.0.name
    "csi.storage.k8s.io/node-publish-secret-namespace" = kubernetes_secret.csi-gcs-creds.metadata.0.namespace
  }
}