locals {
  cis_v160_5_common_tags = merge(local.cis_v160_common_tags, {
    cis_section_id = "5"
  })
}

benchmark "cis_v160_5" {
  title         = "5 Container Runtime Configuration"
  documentation = file("./cis_v160/docs/cis_v160_1.md")
  children = [
    control.cis_v160_5_1,
    control.cis_v160_5_5,
    control.cis_v160_5_6,
  ]

  tags = merge(local.cis_v160_1_common_tags, {
    type = "Benchmark"
  })
}

control "cis_v160_5_1" {
  title         = "5.1 Ensure swarm mode is not Enabled, if not needed"
  description   = "Do not enable swarm mode on a Docker engine instance unless this is needed."
  query         = query.swarm_mode_enabled
  documentation = file("./cis_v160/docs/cis_v160_1_1.md")

  tags = merge(local.cis_v160_1_common_tags, {
    cis_item_id = "5.1"
    cis_level   = "5"
    cis_type    = "manual"
    service     = "Docker"
  })
}

control "cis_v160_5_5" {
  title         = "5.5 Ensure that privileged containers are not used"
  description   = "Using the --privileged flag provides all Linux kernel capabilities to the container to
which it is applied and therefore overwrites the --cap-add and --cap-drop flags. For this
reason we should ensure that it is not used."
  query         = query.privileged_containers
  documentation = file("./cis_v160/docs/cis_v160_1_1.md")

  tags = merge(local.cis_v160_1_common_tags, {
    cis_item_id = "5.5"
    cis_level   = "5"
    cis_type    = "manual"
    service     = "Docker"
  })
}

control "cis_v160_5_6" {
  title         = "5.6 Ensure sensitive host system directories are not mounted on containers"
  description   = "We should not allow sensitive host system directories such as /, /boot, /dev, /etc, /lib, /proc, /sys, /usr to be mounted as container volumes, especially in read-write mode."
  query         = query.host_system_directories_mounted_on_containers
  documentation = file("./cis_v160/docs/cis_v160_1_1.md")

  tags = merge(local.cis_v160_1_common_tags, {
    cis_item_id = "5.6"
    cis_level   = "5"
    cis_type    = "manual"
    service     = "Docker"
  })
}