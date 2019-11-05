# common
variable nodes {}
variable sakuracloud_placement_groups {
  type = map
  default = {
    "0" = "@group=a",
    "1" = "@group=b",
    "2" = "@group=c",
    "3" = "@group=d"
  }
}
variable name_prefix {}
variable description {}
variable server_tags { default = [] }

# server
variable core {}
variable memory {}

# network
variable nic {}
variable ipaddresses { default = [] }
variable display_ipaddresses { default = [] }
variable gateway { default = null }
variable nw_mask_len { default = null }
variable additional_nics { default = null }

# disk
variable primary_disk_sizes { default = [100] }
variable disk_tags { default = null }
variable source_archive_id { default = null }
variable cdrom_id { default = null }
variable password {}
variable ssh_key_ids { default = null }
variable disable_pw_auth { default = null }

# dns
variable dns_zone {}
variable ttl {}

# note
variable note_ids { default = null }

# service records
variable service_dns_ids { default = [] }
variable service_dns_types { default = [] }
variable service_dns_names { default = [] }
variable service_dns_values { default = [] }
variable service_dns_ttls { default = [] }


data sakuracloud_zone current { }

module base-instance {
  source = "../instance"

  nodes                        = var.nodes
  sakuracloud_placement_groups = var.sakuracloud_placement_groups
  name_prefix                  = var.name_prefix
  description                  = var.description
  server_tags                  = var.server_tags

  core   = var.core
  memory = var.memory

  nic                 = var.nic
  ipaddresses         = var.ipaddresses
  display_ipaddresses = var.display_ipaddresses
  gateway             = var.gateway
  nw_mask_len         = var.nw_mask_len
  additional_nics     = var.additional_nics

  primary_disk_sizes = var.primary_disk_sizes
  disk_tags          = var.disk_tags
  source_archive_id  = var.source_archive_id
  cdrom_id           = var.cdrom_id
  password           = var.password
  ssh_key_ids        = var.ssh_key_ids
  disable_pw_auth    = var.disable_pw_auth

  dns_zone = var.dns_zone
  ttl      = var.ttl

  note_ids = var.note_ids
}

module service {
  source = "../service-dns"

  service_dns_ids    = var.service_dns_ids
  service_dns_types  = var.service_dns_types
  service_dns_names  = var.service_dns_names
  service_dns_values = var.service_dns_values
  service_dns_ttls   = var.service_dns_ttls
}

