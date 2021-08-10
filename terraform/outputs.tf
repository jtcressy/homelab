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
      id            = zerotier_identity.home.id
      private       = zerotier_identity.home.private_key
      public        = zerotier_identity.home.public_key
      setup_command = <<-EOT
        mkdir -p /mnt/data/zerotier-one && \
        echo "${zerotier_network.jtcressy_net.id}=eth12" > /mnt/data/zerotier-one/devicemap && \
        echo "${zerotier_identity.home.public_key}" > /mnt/data/zerotier-one/identity.public && \
        echo "${zerotier_identity.home.private_key}" > /mnt/data/zerotier-one/identity.secret && \
        docker run -d --name=zerotier-one --device /dev/net/tun -v /mnt/data/zerotier-one:/var/lib/zerotier-one --net=host --cap-add=NET_ADMIN --cap-add=SYS_ADMIN bltavares/zerotier && \
        docker exec zerotier-one zerotier-cli join ${zerotier_network.jtcressy_net.id}
        EOT
    }
  }
  sensitive = true
}
