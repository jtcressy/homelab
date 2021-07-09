//resource helm_release traefik {
//  repository       = "https://containous.github.io/traefik-helm-chart"
//  chart            = "traefik"
//  name             = "traefik"
//  version          = "8.2.0"
//  namespace        = "loadbalancing"
//  cleanup_on_fail  = true
//  create_namespace = true
//  values = [yamlencode({
//    deployment = {
//      enabled        = true
//      replicas       = 3
//      annotations    = {}
//      podAnnotations = {}
//    }
//    additionalArguments = [
//      "--providers.kubernetesingress.ingressendpoint.publishedservice=traefik"
//    ]
//    service = {
//      enabled = true
//      type    = "LoadBalancer"
//      annotations = {
//        "external-dns.alpha.kubernetes.io/hostname" = join(",", formatlist("${var.location}-ingress.%s", var.external_dns.domain_filter))
//        "cloud.google.com/neg"                      = jsonencode({ ingress = true })
//      }
//      spec                     = {}
//      loadBalancerSourceRanges = var.ingress_source_ranges
//    }
//  })]
//  depends_on = [google_container_cluster.cluster]
//}

resource helm_release ambassador {
  repository       = "https://www.getambassador.io"
  chart            = "ambassador"
  version          = "6.3.6"
  name             = "ambassador"
  namespace        = "ambassador"
  cleanup_on_fail  = true
  create_namespace = true
  values = [yamlencode({

  })]
}

resource helm_release external-dns-cloudflare {
  name       = "external-dns-cloudflare"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "external-dns"
  version    = "2.21.0"
  namespace  = "kube-system"
  timeout    = 600
  values = [yamlencode({
    priorityClassName = "system-cluster-critical"
    affinity = {
      podAntiAffinity = {
        requiredDuringSchedulingIgnoredDuringExecution = [
          {
            labelSelector = {
              matchExpressions = [
                {
                  key      = "app.kubernetes.io/instance"
                  operator = "In"
                  values = [
                  "external-dns-cloudflare"]
                }
              ]
            }
            topologyKey = "kubernetes.io/hostname"
          }
        ]
      }
    }
    sources                 = ["service", "ingress", "crd"]
    provider                = "cloudflare"
    publishInternalServices = false
    publishHostIP           = false
    cloudflare = {
      apiToken = var.external_dns.cf_api_token
      apiKey   = var.external_dns.cf_api_key
      email    = var.external_dns.cf_api_email
      proxied  = var.external_dns.proxy
    }
    domainFilters      = var.external_dns.domain_filter
    triggerLoopOnEvent = true
    txtOwnerId         = "gke_${data.google_project.current.project_id}_${data.google_compute_zones.current.names[0]}_${var.name}"
    txtPrefix          = "extdns."
    replicas           = 2
    crd = {
      create = true
    }
    rbac = {
      create               = true
      serviceAccountCreate = true
      serviceAccountName   = "external-dns-cloudflare"
    }
  })]
  depends_on = [google_container_cluster.cluster]
}

resource helm_release velero {
  name             = "velero"
  repository       = "https://vmware-tanzu.github.io/helm-charts"
  chart            = "velero"
  version          = "2.10.0"
  namespace        = "velero"
  create_namespace = true
  timeout          = 600
  values = [yamlencode({
    configuration = {
      provider = "gcp"
      backupStorageLocation = {
        name   = "gcp"
        bucket = "jtcressy-net-velero-backups"
        config = {
          serviceAccount = var.velero_service_account
        }
      }
    }
    initContainers = [
      {
        name  = "velero-plugin-for-gcp"
        image = "velero/velero-plugin-for-gcp:v1.0.1"
        volumeMounts = [
          {
            name      = "plugins"
            mountPath = "/target"
          }
        ]
      }
    ]
    serviceAccount = {
      server = {
        create = true
        name   = "velero"
        annotations = {
          "iam.gke.io/gcp-service-account" = var.velero_service_account
        }
      }
    }
    credentials = {
      useSecret = false
    }
  })]
  depends_on = [google_container_cluster.cluster]
}
