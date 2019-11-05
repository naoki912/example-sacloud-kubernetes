# Secret vars

#---
# provider sacloud
#---

sakuracloud_primary_site_provider = {
  default = {
    token               = ""
    secret              = ""
    zone                = "is1b"
    api_request_timeout = 3600
  }

  dev = {
    token               = ""
    secret              = ""
    zone                = "is1b"
    api_request_timeout = 3600
  }

  prd = {
    token               = ""
    secret              = ""
    zone                = "is1b"
    api_request_timeout = 3600
  }
}

#---
# secret
#---

password = "password"


#---
# network
#---

sakuracloud_network_internet_global = {
  name        = "sw-external"
  description = ""
  tags        = ["global"]
  nw_mask_len = 28
  band_width  = 100
  enable_ipv6 = false
}

sakuracloud_network_switch_internal = {
  name        = "sw-internal"
  description = ""
  tags        = ["internal", "@k8s"]
}

sakuracloud_subnet_internal = {
  nw_address  = "192.168.0.0"
  nw_mask_len = 24
  gateway     = "192.168.0.254"
  iprange     = "192.168.0.0/24"
}


#---
# dns
#---

//ttl = 600

//sakuracloud_dns_example = {
//  name_selectors  = ["example.org"]
//}


#---
# role: compute
#---

sakuracloud_role_kubernetes = {
  cluster_name = "example"

  etcd = {
    nodes                 = 5
    description           = ""
    server_tags           = []
    core                  = 2
    memory                = 4
    primary_disk_sizes    = 20
    allocation_pool_start = "1"  # 192.168.0.1~
  }
  master = {
    nodes                 = 3
    description           = ""
    server_tags           = []
    core                  = 4
    memory                = 8
    primary_disk_sizes    = 40
    allocation_pool_start = "11"  # 192.168.0.11~
  }
  worker = {
    nodes                 = 5
    description           = ""
    server_tags           = []
    core                  = 4
    memory                = 8
    primary_disk_sizes    = 40
    allocation_pool_start = "21" # 192.168.0.21~
  }
}

