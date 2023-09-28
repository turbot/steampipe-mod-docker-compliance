locals {
  cis_v160_6_common_tags = merge(local.cis_v160_common_tags, {
    cis_section_id = "6"
  })
}

locals {
  cis_v160_6_controls = concat(
    contains(var.control_types, "docker") ? [control.cis_v160_6_2] : []
  )
}

benchmark "cis_v160_6" {
  title         = "6 Docker Security Operations"
  documentation = file("./cis_v160/docs/cis_v160_6.md")

  children = local.cis_v160_6_controls

  tags = merge(local.cis_v160_6_common_tags, {
    type = "Benchmark"
  })
}

control "cis_v160_6_2" {
  title         = "6.2 Ensure that container sprawl is avoided"
  description   = "We should not keep a large number of containers on the same host. We should retain containers that are actively in use, and delete ones which are no longer needed."
  query         = query.docker_container_sprawl_avoided
  documentation = file("./cis_v160/docs/cis_v160_6_2.md")

  tags = merge(local.cis_v160_6_common_tags, {
    cis_item_id = "6.2"
    cis_level   = "1"
    cis_type    = "manual"
    service     = "Docker"
  })
}
