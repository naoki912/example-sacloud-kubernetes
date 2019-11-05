output ipaddresses {
  value = sakuracloud_server.base.*.ipaddress
}

output nodes {
  value = [var.nodes]
}

