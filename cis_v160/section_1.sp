locals {
  cis_v160_1_common_tags = merge(local.cis_v160_common_tags, {
    cis_section_id = "1"
  })
}

benchmark "cis_v160_1" {
  title         = "1 Host Configuration"
  documentation = file("./cis_v160/docs/cis_v160_1.md")
  children = [
    benchmark.cis_v160_1_1,
    benchmark.cis_v160_1_2,
  ]

  tags = merge(local.cis_v160_1_common_tags, {
    type = "Benchmark"
  })
}

benchmark "cis_v160_1_1" {
  title         = "1.1 Linux Hosts Specific Configuration"
  documentation = file("./cis_v160/docs/cis_v160_1_1.md")
  children = [
    control.cis_v160_1_1_1,
    # control.cis_v160_1_1_2,
    control.cis_v160_1_1_3,
    # control.cis_v160_1_1_4,
    # control.cis_v160_1_1_5,
    # control.cis_v160_1_1_6,
    # control.cis_v160_1_1_7,
    # control.cis_v160_1_1_8,
    # control.cis_v160_1_1_9,
    # control.cis_v160_1_1_10,
    # control.cis_v160_1_1_11,
    # control.cis_v160_1_1_12,
    # control.cis_v160_1_1_13,
    # control.cis_v160_1_1_14,
    # control.cis_v160_1_1_15,
    # control.cis_v160_1_1_16,
    # control.cis_v160_1_1_17,
    # control.cis_v160_1_1_18,
  ]

  tags = merge(local.cis_v160_1_common_tags, {
    type = "Benchmark"
  })
}

benchmark "cis_v160_1_2" {
  title         = "1.2 General Configuration"
  documentation = file("./cis_v160/docs/cis_v160_1_2.md")
  children = [
    #control.cis_v160_1_2_1,
    #control.cis_v160_1_2_2,
  ]

  tags = merge(local.cis_v160_1_common_tags, {
    type = "Benchmark"
  })
}

control "cis_v160_1_1_1" {
  title       = "1.1.1 Ensure a separate partition for containers has been created"
  description = "All Docker containers and their data and metadata is stored under /var/lib/docker directory. By default, /var/lib/docker should be mounted under either the / or /var partitions dependent on how the Linux operating system in use is configured."
  query       = query.separate_partition_for_containers_created
  #documentation = file("./cis_v160/docs/cis_v160_1_1_1.md")

  tags = merge(local.cis_v160_1_common_tags, {
    cis_item_id = "1.1.1"
    cis_level   = "1"
    cis_type    = "manual"
    service     = "Docker"
  })
}

control "cis_v160_1_1_3" {
  title       = "1.1.3 Ensure auditing is configured for the Docker daemon"
  description = "Audit all Docker daemon activities."
  query       = query.docker_daemon_auditing_configured
  #documentation = file("./cis_v160/docs/cis_v160_1_1_3.md")

  tags = merge(local.cis_v160_1_common_tags, {
    cis_item_id = "1.1.3"
    cis_level   = "1"
    cis_type    = "automated"
    service     = "Docker"
  })
}
