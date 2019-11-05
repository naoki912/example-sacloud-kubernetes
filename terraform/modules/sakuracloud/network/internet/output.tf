output switch_id {
  value = sakuracloud_internet.global.switch_id
}

output iprange {
  value = format(
    "%s/%d",
    sakuracloud_internet.global.nw_address,
    sakuracloud_internet.global.nw_mask_len
  )
}

output nw_mask_len {
  value = sakuracloud_internet.global.nw_mask_len
}

output gateway {
  value = sakuracloud_internet.global.gateway
}

