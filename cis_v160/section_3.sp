locals {
  cis_v160_3_common_tags = merge(local.cis_v160_common_tags, {
    cis_section_id = "3"
  })
}

locals {
  cis_v160_3_docker_controls = []

  cis_v160_3_exec_controls = [control.cis_v160_3_1, control.cis_v160_3_2, control.cis_v160_3_3, control.cis_v160_3_4, control.cis_v160_3_5, control.cis_v160_3_6, control.cis_v160_3_7, control.cis_v160_3_8, control.cis_v160_3_9, control.cis_v160_3_10, control.cis_v160_3_11, control.cis_v160_3_12, control.cis_v160_3_13, control.cis_v160_3_14, control.cis_v160_3_15, control.cis_v160_3_16, control.cis_v160_3_17, control.cis_v160_3_18, control.cis_v160_3_19, control.cis_v160_3_20, control.cis_v160_3_21, control.cis_v160_3_22, control.cis_v160_3_23, control.cis_v160_3_24
  ]
}

locals {
  cis_v160_3_controls = concat(
    contains(var.control_types, "docker") ? local.cis_v160_3_docker_controls : [],
    contains(var.control_types, "exec") ? local.cis_v160_3_exec_controls : [],
  )
}

benchmark "cis_v160_3" {
  title = "3 Docker daemon configuration files"
  #documentation = file("./cis_v160/docs/cis_v160_3.md")

  children = local.cis_v160_3_controls

  tags = merge(local.cis_v160_3_common_tags, {
    type = "Benchmark"
  })
}

control "cis_v160_3_1" {
  title       = "3.1 Ensure that the docker.service file ownership is set to root:root"
  description = "You should verify that the docker.service file ownership and group ownership are correctly set to root."
  query       = query.docker_service_file_ownership_root_root
  #documentation = file("./cis_v160/docs/cis_v160_1_1_1.md")

  tags = merge(local.cis_v160_3_common_tags, {
    cis_item_id = "3.1"
    cis_level   = "1"
    cis_type    = "automated"
    service     = "Docker"
  })
}

control "cis_v160_3_2" {
  title       = "3.2 Ensure that docker.service file permissions are appropriately set"
  description = "You should verify that the docker.service file permissions are either set to 644 or to a more restrictive value."
  query       = query.docker_service_file_restrictive_permission
  #documentation = file("./cis_v160/docs/cis_v160_1_1_1.md")

  tags = merge(local.cis_v160_3_common_tags, {
    cis_item_id = "3.2"
    cis_level   = "1"
    cis_type    = "automated"
    service     = "Docker"
  })
}

control "cis_v160_3_3" {
  title       = "3.3 Ensure that docker.socket file ownership is set to root:root"
  description = "You should verify that the docker.socket file ownership and group ownership are correctly set to root."
  query       = query.docker_socket_file_ownership_set_to_root
  #documentation = file("./cis_v160/docs/cis_v160_1_1_1.md")

  tags = merge(local.cis_v160_3_common_tags, {
    cis_item_id = "3.3"
    cis_level   = "3"
    cis_type    = "automated"
    service     = "Docker"
  })
}

control "cis_v160_3_4" {
  title       = "3.4 Ensure that docker.socket file permissions are set to 644 or more restrictive "
  description = "You should verify that the file permissions on the docker.socket file are correctly set to 644 or more restrictively."
  query       = query.docker_socket_file_restrictive_permission
  #documentation = file("./cis_v160/docs/cis_v160_1_1_1.md")

  tags = merge(local.cis_v160_3_common_tags, {
    cis_item_id = "3.4"
    cis_level   = "1"
    cis_type    = "automated"
    service     = "Docker"
  })
}

control "cis_v160_3_5" {
  title       = "3.5 Ensure that the /etc/docker directory ownership is set to root:root"
  description = "You should verify that the /etc/docker directory ownership and group ownership is correctly set to root."
  query       = query.etc_docker_directory_ownership_set_to_root
  #documentation = file("./cis_v160/docs/cis_v160_1_1_1.md")

  tags = merge(local.cis_v160_3_common_tags, {
    cis_item_id = "3.5"
    cis_level   = "3"
    cis_type    = "automated"
    service     = "Docker"
  })
}

control "cis_v160_3_6" {
  title       = "3.6 Ensure that /etc/docker directory permissions are set to 755 or more restrictively"
  description = "You should verify that the /etc/docker directory permissions are correctly set to 755 or more restrictively."
  query       = query.etc_docker_directory_restrictive_permission
  #documentation = file("./cis_v160/docs/cis_v160_1_1_1.md")

  tags = merge(local.cis_v160_3_common_tags, {
    cis_item_id = "3.6"
    cis_level   = "1"
    cis_type    = "automated"
    service     = "Docker"
  })
}

control "cis_v160_3_7" {
  title       = "3.7 Ensure that registry certificate file ownership is set to root:root"
  description = "You should verify that all the registry certificate files (usually found under /etc/docker/certs.d/<registry-name> directory) are individually owned and group owned by root."
  query       = query.registry_certificate_ownership_root_root
  #documentation = file("./cis_v160/docs/cis_v160_1_1_1.md")

  tags = merge(local.cis_v160_3_common_tags, {
    cis_item_id = "3.7"
    cis_level   = "1"
    cis_type    = "manual"
    service     = "Docker"
  })
}

control "cis_v160_3_8" {
  title       = "3.8 Ensure that registry certificate file permissions are set to 444 or more restrictively"
  description = "You should verify that all the registry certificate files (usually found under /etc/docker/certs.d/<registry-name> directory) have permissions of 444 or are set more restrictively."
  query       = query.registry_certificate_file_permissions_444
  #documentation = file("./cis_v160/docs/cis_v160_1_1_1.md")

  tags = merge(local.cis_v160_3_common_tags, {
    cis_item_id = "3.8"
    cis_level   = "1"
    cis_type    = "manual"
    service     = "Docker"
  })
}

control "cis_v160_3_9" {
  title       = "3.9 Ensure that TLS CA certificate file ownership is set to root:root"
  description = "You should verify that the TLS CA certificate file (the file that is passed along with the -- tlscacert parameter) is individually owned and group owned by root."
  query       = query.tls_ca_certificate_ownership_root_root
  #documentation = file("./cis_v160/docs/cis_v160_1_1_1.md")

  tags = merge(local.cis_v160_3_common_tags, {
    cis_item_id = "3.9"
    cis_level   = "1"
    cis_type    = "manual"
    service     = "Docker"
  })
}

control "cis_v160_3_10" {
  title       = "3.10 Ensure that TLS CA certificate file permissions are set to 444 or more restrictively"
  description = "You should verify that the TLS CA certificate file (the file that is passed along with the -- tlscacert parameter) has permissions of 444 or is set more restrictively."
  query       = query.tls_ca_certificate_permission_444
  #documentation = file("./cis_v160/docs/cis_v160_1_1_1.md")

  tags = merge(local.cis_v160_3_common_tags, {
    cis_item_id = "3.10"
    cis_level   = "1"
    cis_type    = "manual"
    service     = "Docker"
  })
}

control "cis_v160_3_11" {
  title       = "3.11 Ensure that Docker server certificate file ownership is set to root:root"
  description = "You should verify that the Docker server certificate file (the file that is passed along with the --tlscert parameter) is individual owned and group owned by root."
  query       = query.docker_server_certificate_ownership_root_root
  #documentation = file("./cis_v160/docs/cis_v160_1_1_1.md")

  tags = merge(local.cis_v160_3_common_tags, {
    cis_item_id = "3.11"
    cis_level   = "1"
    cis_type    = "manual"
    service     = "Docker"
  })
}

control "cis_v160_3_12" {
  title       = "3.12 Ensure that the Docker server certificate file permissions are set to 444 or more restrictively"
  description = "You should verify that the Docker server certificate file (the file that is passed along with the --tlscert parameter) has permissions of 444 or more restrictive permissions."
  query       = query.docker_server_certificate_permission_444
  #documentation = file("./cis_v160/docs/cis_v160_1_1_1.md")

  tags = merge(local.cis_v160_3_common_tags, {
    cis_item_id = "3.12"
    cis_level   = "1"
    cis_type    = "manual"
    service     = "Docker"
  })
}

control "cis_v160_3_13" {
  title       = "3.13 Ensure that the Docker server certificate key file ownership is set to root:root"
  description = "You should verify that the Docker server certificate key file (the file that is passed along with the --tlskey parameter) is individually owned and group owned by root."
  query       = query.docker_server_certificate_key_ownership_root_root
  #documentation = file("./cis_v160/docs/cis_v160_1_1_1.md")

  tags = merge(local.cis_v160_3_common_tags, {
    cis_item_id = "3.13"
    cis_level   = "1"
    cis_type    = "manual"
    service     = "Docker"
  })
}

control "cis_v160_3_14" {
  title       = "3.14 Ensure that the Docker server certificate key file permissions are set to 400"
  description = "You should verify that the Docker server certificate key file (the file that is passed along with the --tlskey parameter) has permissions of 400."
  query       = query.docker_server_certificate_key_permission_400
  #documentation = file("./cis_v160/docs/cis_v160_1_1_1.md")

  tags = merge(local.cis_v160_3_common_tags, {
    cis_item_id = "3.13"
    cis_level   = "1"
    cis_type    = "manual"
    service     = "Docker"
  })
}

control "cis_v160_3_15" {
  title       = "3.15 Ensure that the Docker socket file ownership is set to root:docker"
  description = "You should verify that the Docker socket file is owned by root and group owned by docker."
  query       = query.docker_socket_file_ownership_root_docker
  #documentation = file("./cis_v160/docs/cis_v160_1_1_1.md")

  tags = merge(local.cis_v160_3_common_tags, {
    cis_item_id = "3.15"
    cis_level   = "2"
    cis_type    = "manual"
    service     = "Docker"
  })
}

control "cis_v160_3_16" {
  title       = "3.16 Ensure that the Docker sock file permissions are set to 660 or more restrictively"
  description = "You should verify that the Docker socket file has permissions of 660 or are configured more restrictively."
  query       = query.docker_sock_file_restrictive_permission
  #documentation = file("./cis_v160/docs/cis_v160_1_1_1.md")

  tags = merge(local.cis_v160_3_common_tags, {
    cis_item_id = "3.16"
    cis_level   = "1"
    cis_type    = "automated"
    service     = "Docker"
  })
}

control "cis_v160_3_17" {
  title       = "3.17 Ensure that the daemon.json file ownership is set to root:root"
  description = "You should verify that the daemon.json file individual ownership and group ownership is correctly set to root, if it is in use."
  query       = query.daemon_json_file_ownership_root_root
  #documentation = file("./cis_v160/docs/cis_v160_1_1_1.md")

  tags = merge(local.cis_v160_3_common_tags, {
    cis_item_id = "3.17"
    cis_level   = "2"
    cis_type    = "manual"
    service     = "Docker"
  })
}

control "cis_v160_3_18" {
  title       = "3.18 Ensure that daemon.json file permissions are set to 644 or more restrictive"
  description = "You should verify that if the daemon.json is present its file permissions are correctly set to 644 or more restrictively."
  query       = query.daemon_json_file_restrictive_permission
  #documentation = file("./cis_v160/docs/cis_v160_1_1_1.md")

  tags = merge(local.cis_v160_3_common_tags, {
    cis_item_id = "3.18"
    cis_level   = "2"
    cis_type    = "manual"
    service     = "Docker"
  })
}

control "cis_v160_3_19" {
  title       = "3.19 Ensure that the /etc/default/docker file ownership is set to root:root"
  description = "You should verify that the /etc/default/docker file ownership and group-ownership is correctly set to root."
  query       = query.etc_default_docker_file_ownership_root_root
  #documentation = file("./cis_v160/docs/cis_v160_1_1_1.md")

  tags = merge(local.cis_v160_3_common_tags, {
    cis_item_id = "3.19"
    cis_level   = "2"
    cis_type    = "manual"
    service     = "Docker"
  })
}

control "cis_v160_3_20" {
  title       = "3.20 Ensure that the /etc/default/docker file permissions are set to 644 or more restrictively"
  description = "You should verify that the /etc/default/docker file permissions are correctly set to 644 or more restrictively."
  query       = query.etc_default_docker_file_restrictive_permission
  #documentation = file("./cis_v160/docs/cis_v160_1_1_1.md")

  tags = merge(local.cis_v160_3_common_tags, {
    cis_item_id = "3.20"
    cis_level   = "2"
    cis_type    = "manual"
    service     = "Docker"
  })
}

control "cis_v160_3_21" {
  title       = "3.21 Ensure that the /etc/sysconfig/docker file permissions are set to 644 or more restrictively"
  description = "You should verify that the /etc/sysconfig/docker file permissions are correctly set to 644 or more restrictively."
  query       = query.etc_sysconfig_docker_file_restrictive_permission
  #documentation = file("./cis_v160/docs/cis_v160_1_1_1.md")

  tags = merge(local.cis_v160_3_common_tags, {
    cis_item_id = "3.21"
    cis_level   = "2"
    cis_type    = "manual"
    service     = "Docker"
  })
}

control "cis_v160_3_22" {
  title       = "3.22 Ensure that the /etc/sysconfig/docker file ownership is set to root:root"
  description = "You should verify that the /etc/sysconfig/docker file individual ownership and group ownership is correctly set to root."
  query       = query.etc_sysconfig_docker_file_ownership_root_root
  #documentation = file("./cis_v160/docs/cis_v160_1_1_1.md")

  tags = merge(local.cis_v160_3_common_tags, {
    cis_item_id = "3.22"
    cis_level   = "1"
    cis_type    = "manual"
    service     = "Docker"
  })
}

control "cis_v160_3_23" {
  title       = "3.23 Ensure that the Containerd socket file ownership is set to root:root"
  description = "You should verify that the Containerd socket file is owned by root and group owned by root."
  query       = query.docker_containerd_socket_file_ownership_root_root
  #documentation = file("./cis_v160/docs/cis_v160_1_1_1.md")

  tags = merge(local.cis_v160_3_common_tags, {
    cis_item_id = "3.23"
    cis_level   = "1"
    cis_type    = "automated"
    service     = "Docker"
  })
}

control "cis_v160_3_24" {
  title       = "3.24 Ensure that the Containerd socket file permissions are set to 660 or more restrictively"
  description = "You should verify that the Containerd socket file has permissions of 660 or are configured more restrictively."
  query       = query.docker_containerd_socket_file_restrictive_permission
  #documentation = file("./cis_v160/docs/cis_v160_1_1_1.md")

  tags = merge(local.cis_v160_3_common_tags, {
    cis_item_id = "3.24"
    cis_level   = "1"
    cis_type    = "automated"
    service     = "Docker"
  })
}
