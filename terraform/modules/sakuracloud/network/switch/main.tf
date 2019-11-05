variable sakuracloud_switch {
  type = object({
    name        = string
    description = string
    tags        = list(string)
  })
}

resource sakuracloud_switch internal {
  name        = var.sakuracloud_switch.name
  description = var.sakuracloud_switch.description
  tags        = var.sakuracloud_switch.tags
}

