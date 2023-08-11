locals {
  cis_v160_2_common_tags = merge(local.cis_v160_common_tags, {
    cis_section_id = "2"
  })
}

benchmark "cis_v160_2" {
  title         = "2 Docker daemon configuration"
  documentation = file("./cis_v160/docs/cis_v160_2.md")
  children = [
    control.cis_v160_2_1,
    control.cis_v160_2_2,
    control.cis_v160_2_3,
    control.cis_v160_2_5,
    control.cis_v160_2_6,
    control.cis_v160_2_9,
    control.cis_v160_2_13,
    control.cis_v160_2_15,
    control.cis_v160_2_17
  ]

  tags = merge(local.cis_v160_2_common_tags, {
    type = "Benchmark"
  })
}

control "cis_v160_2_1" {
  title       = "2.1 Run the Docker daemon as a non-root user, if possible"
  description = "Rootless mode executes the Docker daemon and containers inside a user namespace, with both the daemon and the container are running without root privileges."
  query       = query.docker_daemon_run_as_root_user
  #documentation = file("./cis_v160/docs/cis_v160_2_1.md")

  tags = merge(local.cis_v160_2_common_tags, {
    cis_item_id = "2.1"
    cis_level   = "2"
    cis_type    = "manual"
    service     = "Docker"
  })
}

control "cis_v160_2_2" {
  title         = "2.2 Ensure network traffic is restricted between containers on the default bridge"
  description   = "By default, all network traffic is allowed between containers on the same host on the default network bridge. If not desired, restrict all inter-container communication. Link specific containers together that require communication. Alternatively, you can create custom network and only join containers that need to communicate to that custom network."
  query         = query.network_traffic_restricted_between_containers
  documentation = file("./cis_v160/docs/cis_v160_2_2.md")

  tags = merge(local.cis_v160_2_common_tags, {
    cis_item_id = "2.2"
    cis_level   = "2"
    cis_type    = "manual"
    service     = "Docker"
  })
}

control "cis_v160_2_3" {
  title       = "2.3 Ensure the logging level is set to 'info'"
  description = "Set Docker daemon log level to info."
  query       = query.logging_level_set_to_info
  #documentation = file("./cis_v160/docs/cis_v160_2_3.md")

  tags = merge(local.cis_v160_2_common_tags, {
    cis_item_id = "2.3"
    cis_level   = "2"
    cis_type    = "manual"
    service     = "Docker"
  })
}

control "cis_v160_2_4" {
  title       = "2.3 Ensure Docker is allowed to make changes to iptables '"
  description = "The iptables firewall is used to set up, maintain, and inspect the tables of IP packet filter rules within the Linux kernel. The Docker daemon should be allowed to make changes to the iptables ruleset."
  query       = query.docker_iptables_not_set
  #documentation = file("./cis_v160/docs/cis_v160_2_3.md")

  tags = merge(local.cis_v160_2_common_tags, {
    cis_item_id = "2.4"
    cis_level   = "1"
    cis_type    = "manual"
    service     = "Docker"
  })
}

control "cis_v160_2_5" {
  title         = "2.5 Ensure insecure registries are not used"
  description   = "Docker considers a private registry either secure or insecure. By default, registries are considered secure."
  query         = query.insecure_registries_unused
  documentation = file("./cis_v160/docs/cis_v160_2_5.md")

  tags = merge(local.cis_v160_2_common_tags, {
    cis_item_id = "2.5"
    cis_level   = "2"
    cis_type    = "manual"
    service     = "Docker"
  })
}

control "cis_v160_2_6" {
  title         = "2.6 Ensure aufs storage driver is not used"
  description   = "Do not use aufs as the storage driver for your Docker instance."
  query         = query.aufs_storage_driver_unused
  documentation = file("./cis_v160/docs/cis_v160_2_6.md")

  tags = merge(local.cis_v160_2_common_tags, {
    cis_item_id = "2.6"
    cis_level   = "2"
    cis_type    = "manual"
    service     = "Docker"
  })
}

control "cis_v160_2_9" {
  title         = "2.9 Enable user namespace support"
  description   = "We should enable user namespace support in Docker daemon to utilize container user to host user re-mapping. This recommendation is beneficial where the containers you are using do not have an explicit container user defined in the container image. If the container images that you are using have a pre-defined non-root user, this recommendation may be skipped as this feature is still in its infancy, and might result in unpredictable issues or difficulty in configuration."
  query         = query.user_namespace_support_enabled
  documentation = file("./cis_v160/docs/cis_v160_2_9.md")

  tags = merge(local.cis_v160_2_common_tags, {
    cis_item_id = "2.9"
    cis_level   = "2"
    cis_type    = "manual"
    service     = "Docker"
  })
}

control "cis_v160_2_13" {
  title         = "2.13 Ensure centralized and remote logging is configured"
  description   = "Docker supports various logging mechanisms. A preferable method for storing logs is one that supports centralized and remote management."
  query         = query.centralized_and_remote_logging_configured
  documentation = file("./cis_v160/docs/cis_v160_2_13.md")

  tags = merge(local.cis_v160_2_common_tags, {
    cis_item_id = "2.13"
    cis_level   = "2"
    cis_type    = "manual"
    service     = "Docker"
  })
}

control "cis_v160_2_14" {
  title         = "2.14 Ensure containers are restricted from acquiring new privileges"
  description   = "By default you should restrict containers from acquiring additional privileges via suid or sgid."
  query         = query.containers_no_new_privilege_disabled
  # documentation = file("./cis_v160/docs/cis_v160_2_14.md")

  tags = merge(local.cis_v160_2_common_tags, {
    cis_item_id = "2.14"
    cis_level   = "1"
    cis_type    = "manual"
    service     = "Docker"
  })
}

control "cis_v160_2_15" {
  title         = "2.15 Ensure live restore is enabled"
  description   = "The --live-restore option enables full support of daemon-less containers within Docker. It ensures that Docker does not stop containers on shutdown or restore and that it properly reconnects to the container when restarted."
  query         = query.live_restore_enabled
  documentation = file("./cis_v160/docs/cis_v160_2_15.md")

  tags = merge(local.cis_v160_2_common_tags, {
    cis_item_id = "2.15"
    cis_level   = "2"
    cis_type    = "manual"
    service     = "Docker"
  })
}

control "cis_v160_2_16" {
  title         = "2.16 Ensure Userland Proxy is Disabled"
  description   = "The Docker daemon starts a userland proxy service for port forwarding whenever a port is exposed. Where hairpin NAT is available, this service is generally superfluous to requirements and can be disabled."
  query         = query.userland_proxy_disabled
  # documentation = file("./cis_v160/docs/cis_v160_2_16.md")

  tags = merge(local.cis_v160_2_common_tags, {
    cis_item_id = "2.16"
    cis_level   = "1"
    cis_type    = "manual"
    service     = "Docker"
  })
}

control "cis_v160_2_17" {
  title         = "2.17 Ensure that a daemon-wide custom seccomp profile is applied if appropriate"
  description   = "You can choose to apply a custom seccomp profile at a daemon-wide level if needed with this overriding Docker's default seccomp profile."
  query         = query.custom_seccomp_profile_applied
  documentation = file("./cis_v160/docs/cis_v160_2_17.md")

  tags = merge(local.cis_v160_2_common_tags, {
    cis_item_id = "2.17"
    cis_level   = "2"
    cis_type    = "manual"
    service     = "Docker"
  })
}
