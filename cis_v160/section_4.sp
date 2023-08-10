locals {
  cis_v160_4_common_tags = merge(local.cis_v160_common_tags, {
    cis_section_id = "4"
  })
}

benchmark "cis_v160_4" {
  title         = "4 Container Images and Build File Configuration"
  documentation = file("./cis_v160/docs/cis_v160_4.md")
  children = [
    control.cis_v160_4_1,
    control.cis_v160_4_5,
    control.cis_v160_4_6,
    control.cis_v160_4_9,
  ]

  tags = merge(local.cis_v160_4_common_tags, {
    type = "Benchmark"
  })
}

control "cis_v160_4_1" {
  title         = "4.1 Ensure that a user for the container has been created"
  description   = "Containers should run as a non-root user."
  query         = query.container_non_root_user
  documentation = file("./cis_v160/docs/cis_v160_4_1.md")

  tags = merge(local.cis_v160_4_common_tags, {
    cis_item_id = "4.1"
    cis_level   = "4"
    cis_type    = "manual"
    service     = "Docker"
  })
}

control "cis_v160_4_5" {
  title         = "4.5 Ensure Content trust for Docker is Enabled"
  description   = "Content trust is disabled by default and should be enabled in line with organizational security policy."
  query         = query.docker_container_trust_enabled
  # documentation = file("./cis_v160/docs/cis_v160_4_5.md")

  tags = merge(local.cis_v160_4_common_tags, {
    cis_item_id = "4.5"
    cis_level   = "2"
    cis_type    = "manual"
    service     = "Docker"
  })
}

control "cis_v160_4_6" {
  title         = "4.6 Ensure that HEALTHCHECK instructions have been added to container images"
  description   = "We should add the HEALTHCHECK instruction to your Docker container images in order to ensure that health checks are executed against running containers."
  query         = query.container_healthcheck_instruction
  documentation = file("./cis_v160/docs/cis_v160_4_6.md")

  tags = merge(local.cis_v160_4_common_tags, {
    cis_item_id = "4.6"
    cis_level   = "4"
    cis_type    = "manual"
    service     = "Docker"
  })
}

control "cis_v160_4_9" {
  title         = "4.9 Ensure that COPY is used instead of ADD in Dockerfiles"
  description   = "We should use the COPY instruction instead of the ADD instruction in the Dockerfile."
  query         = query.dockerfile_add_instruction
  documentation = file("./cis_v160/docs/cis_v160_4_9.md")

  tags = merge(local.cis_v160_4_common_tags, {
    cis_item_id = "4.9"
    cis_level   = "4"
    cis_type    = "manual"
    service     = "Docker"
  })
}
