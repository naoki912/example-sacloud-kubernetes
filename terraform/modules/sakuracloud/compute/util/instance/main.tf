# common
variable nodes {}
variable sakuracloud_placement_groups { type = map }
variable name_prefix {}
variable description {}
variable server_tags { type = list }

# server
variable core {}
variable memory {}

# network
variable nic {}
variable ipaddresses { type = list(string) }
variable display_ipaddresses { type = list(string) }
variable gateway {}
variable nw_mask_len {}
variable additional_nics { type = list(string) }

# disk
variable source_archive_id {}
variable cdrom_id {}
variable disk_tags { type = list(string) }
variable primary_disk_sizes { type = list(number) }
variable password {}
variable ssh_key_ids { type = list(string) }
variable disable_pw_auth {}

# dns
variable dns_zone {}
variable ttl {}

# note
variable note_ids { type = list(string) }


resource sakuracloud_server base {
  count       = var.nodes
  name        = format("%s-%02d", var.name_prefix, count.index)
  description = var.description
  # placement tag + server_tags
  tags        = concat(list( lookup(var.sakuracloud_placement_groups, count.index % length(keys(var.sakuracloud_placement_groups))) ), var.server_tags)

  core   = var.core
  memory = var.memory
  disks  = [sakuracloud_disk.base[count.index].id]

  nic               = var.nic
  ipaddress         = var.nic == "shared" || length(var.ipaddresses) == 0 ? null : var.ipaddresses[count.index]
  # CDROM bootなど、明示的にdisplay_ipaddressの設定が必要になるインスタンス用
  display_ipaddress = var.nic == "shared" || length(var.display_ipaddresses) == 0 ? null : var.display_ipaddresses[count.index]
  gateway           = var.gateway
  nw_mask_len       = var.nw_mask_len
  additional_nics   = var.additional_nics

  graceful_shutdown_timeout = 300

  # Disk
  cdrom_id        = var.cdrom_id
  hostname        = format("%s-%02d", var.name_prefix, count.index)
  password        = var.password
  ssh_key_ids     = var.ssh_key_ids
  disable_pw_auth = var.disable_pw_auth

  # note
  note_ids = var.note_ids

  lifecycle {
    ignore_changes = ["icon_id", "password", "note_ids"]
  }
}

resource sakuracloud_disk base {
  count             = var.nodes
  name              = format("%s-%02d", var.name_prefix, count.index + 1)
  source_archive_id = var.source_archive_id
  # elementはラップアラウンドなので、[100] で定義した場合は全てのdiskが100になる
  # 全てのノードでdiskサイズを変えたい時はnodes分定義する (node数が3なら[20, 40, 100])
  size              = element(var.primary_disk_sizes, count.index)
  # countを利用している場合に1つ前のidを取得する方法、もしくは次に自分のidを渡す方法が無い
  # https://github.com/hashicorp/terraform/issues/14430
  # https://github.com/terraform-providers/terraform-provider-aws/issues/766
  # リストで渡せるようになっているので、もしかしたら複数ディスクを渡せるかもしれない？
  #distant_from      = [count.index > 0 ? sakuracloud_disk.base[count.index - 1].id : null]

  lifecycle {
    ignore_changes = ["source_archive_id", "source_disk_id"]
  }

  tags = var.disk_tags
}

resource sakuracloud_dns_record base {
  count  = var.dns_zone == null ? 0 : var.nodes
  dns_id = var.dns_zone
  name   = format("%s-%02d", var.name_prefix, count.index + 1)
  type   = "A"
  value  = sakuracloud_server.base[count.index].ipaddress
  ttl    = var.ttl
}
