locals {
  cis_v160_7_common_tags = merge(local.cis_v160_common_tags, {
    cis_section_id = "7"
  })
}

locals {
  cis_v160_7_docker_controls = [control.cis_v160_7_1, control.cis_v160_7_5, control.cis_v160_7_7]

  ccis_v160_7_exec_controls = []
}

locals {
  cis_v160_7_controls = concat(
    contains(var.control_types, "docker") ? local.cis_v160_7_docker_controls : [],
    contains(var.control_types, "exec") ? local.ccis_v160_7_exec_controls : [],
  )
}

benchmark "cis_v160_7" {
  title         = "7 Docker Swarm Configuration"
  documentation = file("./cis_v160/docs/cis_v160_7.md")

  children = local.cis_v160_7_controls

  tags = merge(local.cis_v160_7_common_tags, {
    type = "Benchmark"
  })
}

control "cis_v160_7_1" {
  title         = "7.1 Ensure that the minimum number of manager nodes have been created in a swarm"
  description   = "We should ensure that the minimum number of required manager nodes is created in a swarm."
  query         = query.swarm_minimum_required_manager_nodes
  documentation = file("./cis_v160/docs/cis_v160_7_1.md")

  tags = merge(local.cis_v160_7_common_tags, {
    cis_item_id = "7.1"
    cis_level   = "1"
    cis_type    = "manual"
    service     = "Docker"
  })
}

control "cis_v160_7_5" {
  title         = "7.5 Ensure that swarm manager is run in auto-lock mode"
  description   = "We should review whether you wish to run Docker swarm manager in auto-lock mode."
  query         = query.swarm_manager_auto_lock_mode
  documentation = file("./cis_v160/docs/cis_v160_7_5.md")

  tags = merge(local.cis_v160_7_common_tags, {
    cis_item_id = "7.5"
    cis_level   = "1"
    cis_type    = "manual"
    service     = "Docker"
  })
}

control "cis_v160_7_7" {
  title         = "7.7 Ensure that node certificates are rotated as appropriate"
  description   = "We should rotate swarm node certificates in line with your organizational security policy."
  query         = query.swarm_node_cert_expiry_set
  documentation = file("./cis_v160/docs/cis_v160_7_7.md")

  tags = merge(local.cis_v160_7_common_tags, {
    cis_item_id = "7.7"
    cis_level   = "1"
    cis_type    = "manual"
    service     = "Docker"
  })
}
