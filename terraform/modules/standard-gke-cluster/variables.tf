variable name {}
variable location {}
variable csi-gcs-private-key {}
variable kms_key_id {}
variable external_dns {
  type = object({
    cf_api_token  = string
    cf_api_key    = string
    cf_api_email  = string
    proxy         = bool
    domain_filter = list(string)
  })
}

variable ingress_source_ranges {
  default = []
}

variable velero_service_account {}