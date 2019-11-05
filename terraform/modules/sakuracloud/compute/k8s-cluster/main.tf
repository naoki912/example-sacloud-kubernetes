# network
variable switch_id {}
variable nw_mask_len {}
variable gateway {}

# disk
variable password {}
variable ssh_key_ids { type = list(string) }
variable disable_pw_auth {}
variable source_archive_id {}

# dns
variable dns_zone {}
variable ttl {}

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

variable ipaddresses {
  type = object({
    etcd   = list(string)
    master = list(string)
    worker = list(string)
  })
}


locals {
  cluster_name = var.sakuracloud_role_kubernetes.cluster_name

  etcd = {
    nodes                 = var.sakuracloud_role_kubernetes.etcd.nodes
    description           = var.sakuracloud_role_kubernetes.etcd.description
    server_tags           = flatten([
      ["@auto-reboot", "@with_sacloud_inventory", "@sshconfig", "@ssh_user=ubuntu", "@with_kubespray_inventory", "etcd", "kube-node", "@instance-type=etcd"],
      var.sakuracloud_role_kubernetes.etcd.server_tags,
    ])
    core                  = var.sakuracloud_role_kubernetes.etcd.core
    memory                = var.sakuracloud_role_kubernetes.etcd.memory
    primary_disk_sizes    = var.sakuracloud_role_kubernetes.etcd.primary_disk_sizes
    allocation_pool_start = var.sakuracloud_role_kubernetes.etcd.allocation_pool_start
  }

  master = {
    nodes                 = var.sakuracloud_role_kubernetes.master.nodes
    description           = var.sakuracloud_role_kubernetes.master.description
    server_tags           = flatten([
      ["@auto-reboot", "@with_sacloud_inventory", "@sshconfig", "@ssh_user=ubuntu", "@with_kubespray_inventory", "k8s-cluster", "kube-master", "@instance-type=master"],
      var.sakuracloud_role_kubernetes.master.server_tags,
    ])
    core                  = var.sakuracloud_role_kubernetes.master.core
    memory                = var.sakuracloud_role_kubernetes.master.memory
    primary_disk_sizes    = var.sakuracloud_role_kubernetes.master.primary_disk_sizes
    allocation_pool_start = var.sakuracloud_role_kubernetes.master.allocation_pool_start
  }

  worker = {
    nodes                 = var.sakuracloud_role_kubernetes.worker.nodes
    description           = var.sakuracloud_role_kubernetes.worker.description
    server_tags           = flatten([
      ["@auto-reboot", "@with_sacloud_inventory", "@sshconfig", "@ssh_user=ubuntu", "@with_kubespray_inventory", "k8s-cluster", "kube-node", "@instance-type=worker"],
      var.sakuracloud_role_kubernetes.worker.server_tags,
    ])
    core                  = var.sakuracloud_role_kubernetes.worker.core
    memory                = var.sakuracloud_role_kubernetes.worker.memory
    primary_disk_sizes    = var.sakuracloud_role_kubernetes.worker.primary_disk_sizes
    allocation_pool_start = var.sakuracloud_role_kubernetes.worker.allocation_pool_start
  }
}


module etcd {
  source = "../k8s-node"

  name_prefix = join("-", [local.cluster_name, "etcd"])

  # role
  cluster_name                     = local.cluster_name
  sakuracloud_role_kubernetes_node = local.etcd

  # network
  nic             = var.switch_id
  ipaddresses     = var.ipaddresses.etcd
  nw_mask_len     = var.nw_mask_len
  gateway         = var.gateway

  # disk
  disk_tags          = []
  source_archive_id  = var.source_archive_id
  password           = var.password
  ssh_key_ids        = var.ssh_key_ids
  disable_pw_auth    = var.disable_pw_auth

  # dns
  dns_zone      = var.dns_zone
  ttl           = var.ttl
}

module master {
  source = "../k8s-node"

  name_prefix = join("-", [local.cluster_name, "master"])

  # role
  cluster_name                     = local.cluster_name
  sakuracloud_role_kubernetes_node = local.master

  # network
  nic             = var.switch_id
  ipaddresses     = var.ipaddresses.master
  nw_mask_len     = var.nw_mask_len
  gateway         = var.gateway

  # disk
  disk_tags          = []
  source_archive_id  = var.source_archive_id
  password           = var.password
  ssh_key_ids        = var.ssh_key_ids
  disable_pw_auth    = var.disable_pw_auth

  # dns
  dns_zone      = var.dns_zone
  ttl           = var.ttl
}

module worker {
  source = "../k8s-node"

  name_prefix = join("-", [local.cluster_name, "worker"])

  # role
  cluster_name                     = local.cluster_name
  sakuracloud_role_kubernetes_node = local.worker

  # network
  nic             = var.switch_id
  ipaddresses     = var.ipaddresses.worker
  nw_mask_len     = var.nw_mask_len
  gateway         = var.gateway

  # disk
  disk_tags          = []
  source_archive_id  = var.source_archive_id
  password           = var.password
  ssh_key_ids        = var.ssh_key_ids
  disable_pw_auth    = var.disable_pw_auth

  # dns
  dns_zone      = var.dns_zone
  ttl           = var.ttl
}

