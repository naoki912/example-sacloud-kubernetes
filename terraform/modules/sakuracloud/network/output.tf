output global {
  value = {
    switch_id   = module.global.switch_id
    iprange     = module.global.iprange
    nw_mask_len = module.global.nw_mask_len
    gateway     = module.global.gateway
  }
}

output internal {
  value = {
    switch_id   = module.internal.switch_id
  }
}

