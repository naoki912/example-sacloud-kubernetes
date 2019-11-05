# service records
variable service_dns_ids { type = list }
variable service_dns_types { type = list }
variable service_dns_names { type = list }
variable service_dns_values { type = list }
variable service_dns_ttls { type = list }

# service dns records
resource sakuracloud_dns_record service {
  count  = length(var.service_dns_names)
  dns_id = element(var.service_dns_ids, count.index)
  type   = element(var.service_dns_types, count.index)
  name   = element(var.service_dns_names, count.index)
  value  = element(var.service_dns_values, count.index)
  ttl    = element(var.service_dns_ttls, count.index)
}

