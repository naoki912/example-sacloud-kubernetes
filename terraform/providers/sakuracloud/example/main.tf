#--
# providers
#--

variable sakuracloud_primary_site_provider { type = map }

provider sakuracloud {
  token               = var.sakuracloud_primary_site_provider[terraform.workspace].token
  secret              = var.sakuracloud_primary_site_provider[terraform.workspace].secret
  zone                = var.sakuracloud_primary_site_provider[terraform.workspace].zone
  api_request_timeout = tostring(var.sakuracloud_primary_site_provider[terraform.workspace].api_request_timeout)
}


#---
# variables
#---

# switch
variable sakuracloud_network_internet_global {
  type = object({
    name        = string
    description = string
    tags        = list(string)
    nw_mask_len = number
    band_width  = number
    enable_ipv6 = bool
  })
}

variable sakuracloud_network_switch_internal {
  type = object({
    name        = string
    description = string
    tags        = list(string)
  })
}

# subnet
variable sakuracloud_subnet_internal {
  type = object({
    nw_address  = string
    nw_mask_len = number
    gateway     = string
    iprange     = string
  })
}

# disk
variable password {}
variable disable_pw_auth {
  default = false
}

# role
variable sakuracloud_role_kubernetes {
  type = object({
    cluster_name = string
    etcd = object({
      nodes                 = number
      description           = string
      server_tags           = list(string)
      core                  = number
      memory                = number
      primary_disk_sizes    = number
      allocation_pool_start = number
    })
    master = object({
      nodes                 = number
      description           = string
      server_tags           = list(string)
      core                  = number
      memory                = number
      primary_disk_sizes    = number
      allocation_pool_start = number
    })
    worker = object({
      nodes                 = number
      description           = string
      server_tags           = list(string)
      core                  = number
      memory                = number
      primary_disk_sizes    = number
      allocation_pool_start = number
    })
  })
}

#---
# data
#---

# ssh keys
#data sakuracloud_ssh_key example {
#  name_selectors = ["example"]
#}

#---
# modules
#---

module cluster_example {
  source = "../../../modules/sakuracloud/compute/k8s-cluster"

  # network
  switch_id   = module.network.internal.switch_id
  nw_mask_len = var.sakuracloud_subnet_internal.nw_mask_len
  gateway     = var.sakuracloud_subnet_internal.gateway

  # disk
  password          = var.password
  ssh_key_ids       = null
  disable_pw_auth   = var.disable_pw_auth
  source_archive_id = module.archive.public_archive.ubuntu_1804_3.id

  # dns
  dns_zone = null
  ttl      = null

  # role
  sakuracloud_role_kubernetes = var.sakuracloud_role_kubernetes

  ipaddresses = local.ipaddresses_cluster_example
}

module network {
  source = "../../../modules/sakuracloud/network"

  sakuracloud_network_internet_global = var.sakuracloud_network_internet_global
  sakuracloud_network_switch_internal = var.sakuracloud_network_switch_internal
}


module archive {
  source = "../../../modules/sakuracloud/archive"
}


locals {
  #ssh_key_ids = [
  #  data.sakuracloud_ssh_key.example.id
  #]

  ipaddresses_cluster_example = {
    etcd = [
      for num in range(var.sakuracloud_role_kubernetes.etcd.nodes):
      cidrhost(
        var.sakuracloud_subnet_internal.iprange,
        var.sakuracloud_role_kubernetes.etcd.allocation_pool_start + num
      )
    ]
    master = [
      for num in range(var.sakuracloud_role_kubernetes.master.nodes):
      cidrhost(
        var.sakuracloud_subnet_internal.iprange,
        var.sakuracloud_role_kubernetes.master.allocation_pool_start + num
      )
    ]
    worker = [
      for num in range(var.sakuracloud_role_kubernetes.worker.nodes):
      cidrhost(
        var.sakuracloud_subnet_internal.iprange,
        var.sakuracloud_role_kubernetes.worker.allocation_pool_start + num
      )
    ]
  }
}

