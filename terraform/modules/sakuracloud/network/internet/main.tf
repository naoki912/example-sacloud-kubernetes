variable sakuracloud_internet {
  type = object({
    name        = string
    description = string
    tags        = list(string)
    nw_mask_len = number
    band_width  = number
    enable_ipv6 = bool
  })
}

resource sakuracloud_internet global {
  name        = var.sakuracloud_internet.name
  description = var.sakuracloud_internet.description
  nw_mask_len = var.sakuracloud_internet.nw_mask_len
  band_width  = var.sakuracloud_internet.band_width
  enable_ipv6 = var.sakuracloud_internet.enable_ipv6
  tags        = var.sakuracloud_internet.tags
}

