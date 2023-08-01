locals {
  cis_v160_3_common_tags = merge(local.cis_v160_common_tags, {
    cis_section_id = "3"
  })
}

benchmark "cis_v160_3" {
  title = "3 Docker daemon configuration files"
  #documentation = file("./cis_v160/docs/cis_v160_3.md")
  children = [
    control.cis_v160_3_3,
    control.cis_v160_3_5,
  ]

  tags = merge(local.cis_v160_3_common_tags, {
    type = "Benchmark"
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
