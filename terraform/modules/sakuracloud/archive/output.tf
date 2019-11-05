output public_archive {
  value = {
    ubuntu_1804_3 = {
      id = module.public_archive.ubuntu_1804_3_id
    }
    centos_7_7 = {
      id = module.public_archive.centos_7_7_id
    }
  }
}

