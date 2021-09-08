resource "zerotier_network" "jtcressy_net" {
  name        = "jtcressy-net"
  description = "Core SDWAN network for jtcressy.net | Managed by terraform at github.com/jtcressy/homelab"

  enable_broadcast = true
  private          = true
  flow_rules       = <<-EOT
  accept;
  EOT

  assign_ipv4 {
    zerotier = true
  }

  assignment_pool {
    start = "172.23.0.1"
    end   = "172.23.255.254"
  }

  route {
    target = "172.23.0.0/16"
  }

  route {
    target = "192.168.0.0/16"
    via    = "172.23.20.1"
  }
}

resource "zerotier_identity" "home" {}

resource "zerotier_member" "home" {
  name                    = "home"
  member_id               = zerotier_identity.home.id
  network_id              = zerotier_network.jtcressy_net.id
  no_auto_assign_ips      = true
  ip_assignments          = ["172.23.20.1"]
  authorized              = true
  allow_ethernet_bridging = true
}

resource "zerotier_identity" "gh_actions" {}

resource "zerotier_member" "gh_actions" {
  name       = "github actions"
  member_id  = zerotier_identity.gh_actions.id
  network_id = zerotier_network.jtcressy_net.id
  authorized = true
}