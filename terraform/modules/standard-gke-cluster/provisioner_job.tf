resource kubernetes_cluster_role_binding provisioner-job {
  metadata {
    name = "tf-provisioner-job"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.provisioner-job.metadata.0.name
    namespace = "kube-system"
  }
}

resource kubernetes_service_account provisioner-job {
  metadata {
    name      = "tf-provisioner-job"
    namespace = "kube-system"
  }
  automount_service_account_token = true
}

data kubernetes_service kubernetes {
  metadata {
    name      = "kubernetes"
    namespace = "default"
  }
  depends_on = [google_container_cluster.cluster]
}

resource kubernetes_config_map provisioner-job {
  metadata {
    name      = "tf-provisioner-job"
    namespace = "kube-system"
  }
  data = {
    script = <<EOF
#!/bin/bash
set -x
apk add git && \
export KUBE_TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token) && \
export ARGS="--server=https://$KUBERNETES_SERVICE_HOST --token=$KUBE_TOKEN --certificate-authority=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt" && \
kubectl apply -k "github.com/ofek/csi-gcs/deploy/overlays/stable?ref=v0.4.0" && \
mkdir -p /tmp/manifests && \
((cp /provisioner-job/*.yaml /tmp/manifests && \
kubectl $ARGS apply -f /tmp/manifests) || true) && \
echo "DONE!" || exit 1
EOF
  }
  binary_data = {
    for key in keys(local.custom_manifests) :
    "${key}.yaml" => base64encode(local.custom_manifests[key])
  }
}

resource random_pet provisioner-job {
  keepers = {
    data = base64sha256(jsonencode(kubernetes_config_map.provisioner-job.data))
    binary_data = try(
      base64sha256(jsonencode(kubernetes_config_map.provisioner-job.binary_data)),
      ""
    )
  }
  prefix    = "tf-provisioner"
  separator = "-"
}

resource kubernetes_job provisioner-job {
  metadata {
    name      = random_pet.provisioner-job.id
    namespace = "kube-system"
    labels = {
      "app.kubernetes.io/name"     = "tf-provisioner-job"
      "app.kubernetes.io/instance" = random_pet.provisioner-job.id
    }
  }
  spec {
    manual_selector = true
    selector {
      match_labels = {
        "app.kubernetes.io/name"     = "tf-provisioner-job"
        "app.kubernetes.io/instance" = random_pet.provisioner-job.id
      }
    }
    template {
      metadata {
        labels = {
          "eks.amazonaws.com/compute-type" = "fargate"
          "app.kubernetes.io/name"         = "tf-provisioner-job"
          "app.kubernetes.io/instance"     = random_pet.provisioner-job.id
        }
      }
      spec {
        priority_class_name = "system-cluster-critical"

        toleration {
          operator = "Exists"
        }
        automount_service_account_token = true
        service_account_name            = kubernetes_service_account.provisioner-job.metadata.0.name
        volume {
          name = "provisioner-configmap"
          config_map {
            name = "tf-provisioner-job"
          }
        }
        container {
          name  = "runner"
          image = "praqma/helmsman:latest"
          env {
            name  = "KUBECONFIG"
            value = "/provisioner-job/kubeconfig"
          }
          volume_mount {
            mount_path = "/provisioner-job"
            name       = "provisioner-configmap"
          }
          command = [
            "/bin/bash",
            "-c",
            "mkdir -p /tmp && cp /provisioner-job/script /tmp/script && chmod +x /tmp/script && /tmp/script"
          ]
        }
        restart_policy = "Never"
      }
    }
    active_deadline_seconds = 30
    backoff_limit           = 3
  }
}
