locals {
  cis_v160_1_common_tags = merge(local.cis_v160_common_tags, {
    cis_section_id = "1"
  })
}

locals {
  cis_v160_1_1_docker_controls = []

  cis_v160_1_1_exec_controls = [
    control.cis_v160_1_1_1, control.cis_v160_1_1_3, control.cis_v160_1_1_4, control.cis_v160_1_1_5, control.cis_v160_1_1_6, control.cis_v160_1_1_7, control.cis_v160_1_1_8, control.cis_v160_1_1_9, control.cis_v160_1_1_10, control.cis_v160_1_1_11, control.cis_v160_1_1_12, control.cis_v160_1_1_13, control.cis_v160_1_1_14, control.cis_v160_1_1_15, control.cis_v160_1_1_16, control.cis_v160_1_1_17, control.cis_v160_1_1_18
  ]
}

locals {
  cis_v160_1_1_controls = concat(
    contains(var.control_types, "docker") ? local.cis_v160_1_1_docker_controls : [],
    contains(var.control_types, "exec") ? local.cis_v160_1_1_exec_controls : [],
  )
}

benchmark "cis_v160_1" {
  title         = "1 Host Configuration"
  documentation = file("./cis_v160/docs/cis_v160_1.md")
  children = [
    benchmark.cis_v160_1_1
  ]

  tags = merge(local.cis_v160_1_common_tags, {
    type = "Benchmark"
  })
}

benchmark "cis_v160_1_1" {
  title         = "1.1 Linux Hosts Specific Configuration"
  documentation = file("./cis_v160/docs/cis_v160_1_1.md")

  children = local.cis_v160_1_1_controls

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

control "cis_v160_1_1_4" {
  title       = "1.1.4 Ensure auditing is configured for Docker files and directories - /run/containerd"
  description = "Audit /run/containerd."
  query       = query.docker_files_and_directories_run_containerd_auditing_configured
  #documentation = file("./cis_v160/docs/cis_v160_1_1_4.md")

  tags = merge(local.cis_v160_1_common_tags, {
    cis_item_id = "1.1.4"
    cis_level   = "1"
    cis_type    = "automated"
    service     = "Docker"
  })
}

control "cis_v160_1_1_5" {
  title       = "1.1.5 Ensure auditing is configured for Docker files and directories - /var/lib/docker"
  description = "Audit /var/lib/docker."
  query       = query.docker_files_and_directories_var_lib_docker_auditing_configured
  #documentation = file("./cis_v160/docs/cis_v160_1_1_5.md")

  tags = merge(local.cis_v160_1_common_tags, {
    cis_item_id = "1.1.5"
    cis_level   = "1"
    cis_type    = "manual"
    service     = "Docker"
  })
}

control "cis_v160_1_1_6" {
  title       = "1.1.6 Ensure auditing is configured for Docker files and directories - /etc/docker"
  description = "Audit /etc/docker."
  query       = query.docker_files_and_directories_etc_docker_auditing_configured
  #documentation = file("./cis_v160/docs/cis_v160_1_1_6.md")

  tags = merge(local.cis_v160_1_common_tags, {
    cis_item_id = "1.1.6"
    cis_level   = "1"
    cis_type    = "automated"
    service     = "Docker"
  })
}

control "cis_v160_1_1_7" {
  title       = "1.1.7 Ensure auditing is configured for Docker files and directories - docker.service"
  description = "Audit the docker.service if applicable."
  query       = query.docker_files_and_directories_docker_service_auditing_configured
  #documentation = file("./cis_v160/docs/cis_v160_1_1_7.md")

  tags = merge(local.cis_v160_1_common_tags, {
    cis_item_id = "1.1.7"
    cis_level   = "1"
    cis_type    = "automated"
    service     = "Docker"
  })
}

control "cis_v160_1_1_8" {
  title       = "1.1.8 Ensure auditing is configured for Docker files and directories - containerd.sock"
  description = "Audit containerd.sock, if applicable."
  query       = query.docker_files_and_directories_containerd_sock_auditing_configured
  #documentation = file("./cis_v160/docs/cis_v160_1_1_8.md")

  tags = merge(local.cis_v160_1_common_tags, {
    cis_item_id = "1.1.8"
    cis_level   = "2"
    cis_type    = "automated"
    service     = "Docker"
  })
}

control "cis_v160_1_1_9" {
  title       = "1.1.9 Ensure auditing is configured for Docker files and directories - docker.socket"
  description = "Audit docker.socket, if applicable."
  query       = query.docker_files_and_directories_docker_socket_auditing_configured
  #documentation = file("./cis_v160/docs/cis_v160_1_1_8.md")

  tags = merge(local.cis_v160_1_common_tags, {
    cis_item_id = "1.1.9"
    cis_level   = "2"
    cis_type    = "automated"
    service     = "Docker"
  })
}

control "cis_v160_1_1_10" {
  title       = "1.1.10 Ensure auditing is configured for Docker files and directories - /etc/default/docker"
  description = "Audit /etc/default/docker, if applicable."
  query       = query.docker_files_and_directories_etc_default_docker_auditing_configured
  #documentation = file("./cis_v160/docs/cis_v160_1_1_10.md")

  tags = merge(local.cis_v160_1_common_tags, {
    cis_item_id = "1.1.10"
    cis_level   = "2"
    cis_type    = "automated"
    service     = "Docker"
  })
}

control "cis_v160_1_1_11" {
  title       = "1.1.11 Ensure auditing is configured for Docker files and directories - /etc/docker/daemon.json"
  description = "Audit /etc/docker/daemon.json, if applicable."
  query       = query.docker_files_and_directories_etc_docker_daemon_auditing_configured
  #documentation = file("./cis_v160/docs/cis_v160_1_1_11.md")

  tags = merge(local.cis_v160_1_common_tags, {
    cis_item_id = "1.1.11"
    cis_level   = "2"
    cis_type    = "automated"
    service     = "Docker"
  })
}

control "cis_v160_1_1_12" {
  title       = "1.1.12 Ensure auditing is configured for Docker files and directories - /etc/containerd/config.toml"
  description = "Audit /etc/containerd/config.toml if applicable"
  query       = query.docker_files_and_directories_etc_containerd_config_auditing_configured
  #documentation = file("./cis_v160/docs/cis_v160_1_1_12.md")

  tags = merge(local.cis_v160_1_common_tags, {
    cis_item_id = "1.1.12"
    cis_level   = "2"
    cis_type    = "automated"
    service     = "Docker"
  })
}

control "cis_v160_1_1_13" {
  title       = "1.1.13 Ensure auditing is configured for Docker files and directories - /etc/sysconfig/docker"
  description = "Audit /etc/sysconfig/docker if applicable"
  query       = query.docker_files_and_directories_etc_sysconfig_docker_auditing_configured
  #documentation = file("./cis_v160/docs/cis_v160_1_1_13.md")

  tags = merge(local.cis_v160_1_common_tags, {
    cis_item_id = "1.1.13"
    cis_level   = "2"
    cis_type    = "automated"
    service     = "Docker"
  })
}

control "cis_v160_1_1_14" {
  title       = "1.1.14 Ensure auditing is configured for Docker files and directories - /usr/bin/containerd"
  description = "Audit /usr/bin/containerd if applicable."
  query       = query.docker_files_and_directories_usr_bin_containerd_auditing_configured
  #documentation = file("./cis_v160/docs/cis_v160_1_1_14.md")

  tags = merge(local.cis_v160_1_common_tags, {
    cis_item_id = "1.1.14"
    cis_level   = "2"
    cis_type    = "automated"
    service     = "Docker"
  })
}

control "cis_v160_1_1_15" {
  title       = "1.1.15 Ensure auditing is configured for Docker files and directories - /usr/bin/containerd-shim"
  description = "Audit /usr/bin/containerd-shim if applicable."
  query       = query.docker_files_and_directories_usr_bin_containerd_shim_auditing_configured
  #documentation = file("./cis_v160/docs/cis_v160_1_1_15.md")

  tags = merge(local.cis_v160_1_common_tags, {
    cis_item_id = "1.1.15"
    cis_level   = "2"
    cis_type    = "manual"
    service     = "Docker"
  })
}

control "cis_v160_1_1_16" {
  title       = "1.1.16 Ensure auditing is configured for Docker files and directories - /usr/bin/containerd-shim-runc-v1"
  description = "Audit /usr/bin/containerd-shim-runc-v1 if applicable."
  query       = query.docker_files_and_directories_usr_bin_containerd_shim_runc_v1_auditing_configured
  #documentation = file("./cis_v160/docs/cis_v160_1_1_16.md")

  tags = merge(local.cis_v160_1_common_tags, {
    cis_item_id = "1.1.16"
    cis_level   = "2"
    cis_type    = "manual"
    service     = "Docker"
  })
}

control "cis_v160_1_1_17" {
  title       = "1.1.17 Ensure auditing is configured for Docker files and directories - /usr/bin/containerd-shim-runc-v2"
  description = "Audit /usr/bin/containerd-shim-runc-v2 if applicable"
  query       = query.docker_files_and_directories_usr_bin_containerd_shim_runc_v2_auditing_configured
  #documentation = file("./cis_v160/docs/cis_v160_1_1_17.md")

  tags = merge(local.cis_v160_1_common_tags, {
    cis_item_id = "1.1.17"
    cis_level   = "2"
    cis_type    = "manual"
    service     = "Docker"
  })
}

control "cis_v160_1_1_18" {
  title       = "1.1.18 Ensure auditing is configured for Docker files and directories - /usr/bin/runc"
  description = "Audit /usr/bin/runc if applicable"
  query       = query.docker_files_and_directories_usr_bin_runc_auditing_configured
  #documentation = file("./cis_v160/docs/cis_v160_1_1_18.md")

  tags = merge(local.cis_v160_1_common_tags, {
    cis_item_id = "1.1.18"
    cis_level   = "2"
    cis_type    = "manual"
    service     = "Docker"
  })
}
