# common
variable name_prefix {}

# network
variable nic {}
variable ipaddresses { type = list(string) }
variable nw_mask_len {}
variable gateway {}

# disk
variable disk_tags { default = [] }
variable password {}
variable ssh_key_ids { type = list(string) }
variable disable_pw_auth {}
variable source_archive_id {}

# dns
variable dns_zone {}
variable ttl {}

# role
variable cluster_name {}
variable sakuracloud_role_kubernetes_node {
  type = object({
    nodes                 = number
    description           = string
    server_tags           = list(string)
    core                  = number
    memory                = number
    primary_disk_sizes    = number
    allocation_pool_start = number
  })
}


module node {
  source = "../util/base-wrapper"

  nodes       = var.sakuracloud_role_kubernetes_node.nodes
  name_prefix = var.name_prefix

  description = var.sakuracloud_role_kubernetes_node.description
  server_tags = flatten([
    var.sakuracloud_role_kubernetes_node.server_tags,
    format("@cluster=%s", var.cluster_name)
  ])

  core   = var.sakuracloud_role_kubernetes_node.core
  memory = var.sakuracloud_role_kubernetes_node.memory

  nic         = var.nic
  ipaddresses = var.ipaddresses
  nw_mask_len = var.nw_mask_len
  gateway     = var.gateway

  primary_disk_sizes = [var.sakuracloud_role_kubernetes_node.primary_disk_sizes]
  disk_tags          = flatten([
    var.disk_tags,
    format("@cluster=%s", var.cluster_name)
  ])
  source_archive_id  = var.source_archive_id
  password           = var.password
  ssh_key_ids        = var.ssh_key_ids
  disable_pw_auth    = var.disable_pw_auth

  # dns
  dns_zone = var.dns_zone
  ttl      = var.ttl
}

