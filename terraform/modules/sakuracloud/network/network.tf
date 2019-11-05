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


module global {
  source = "./internet"

  sakuracloud_internet = var.sakuracloud_network_internet_global
}

module internal {
  source = "./switch"

  sakuracloud_switch = var.sakuracloud_network_switch_internal
}

