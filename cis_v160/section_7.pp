locals {
  cis_v160_7_common_tags = merge(local.cis_v160_common_tags, {
    cis_section_id = "7"
  })
}

locals {
  cis_v160_7_controls = concat(
    contains(var.benchmark_plugins, "docker") ? [control.cis_v160_7_1] : list([]),
    contains(var.benchmark_plugins, "exec") ? [control.cis_v160_7_2] : list([]),
    contains(var.benchmark_plugins, "docker") ? [control.cis_v160_7_5, control.cis_v160_7_7] : list([]),
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
  query         = query.docker_info_swarm_minimum_required_manager_nodes
  documentation = file("./cis_v160/docs/cis_v160_7_1.md")

  tags = merge(local.cis_v160_7_common_tags, {
    cis_item_id = "7.1"
    cis_level   = "1"
    cis_type    = "manual"
    service     = "Docker"
  })
}

control "cis_v160_7_2" {
  title         = "7.2 Ensure that swarm services are bound to a specific host interface"
  description   = "By default, Docker swarm services will listen on all interfaces on the host. This may not be necessary for the operation of the swarm where the host has multiple network interfaces."
  query         = query.exec_swarm_services_bound_to_specific_host_interface
  documentation = file("./cis_v160/docs/cis_v160_7_1.md")

  tags = merge(local.cis_v160_7_common_tags, {
    cis_item_id = "7.2"
    cis_level   = "1"
    cis_type    = "manual"
    service     = "Docker"
  })
}

control "cis_v160_7_5" {
  title         = "7.5 Ensure that swarm manager is run in auto-lock mode"
  description   = "We should review whether you wish to run Docker swarm manager in auto-lock mode."
  query         = query.docker_info_swarm_manager_auto_lock_mode
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
  query         = query.docker_info_swarm_node_cert_expiry_set
  documentation = file("./cis_v160/docs/cis_v160_7_7.md")

  tags = merge(local.cis_v160_7_common_tags, {
    cis_item_id = "7.7"
    cis_level   = "1"
    cis_type    = "manual"
    service     = "Docker"
  })
}
