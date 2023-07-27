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
    control.cis_v160_5_2,
    control.cis_v160_5_5,
    control.cis_v160_5_6,
    control.cis_v160_5_10,
    control.cis_v160_5_11,
    control.cis_v160_5_12,
    control.cis_v160_5_13,
    control.cis_v160_5_15,
    control.cis_v160_5_16,
    control.cis_v160_5_17,
    control.cis_v160_5_18,
    control.cis_v160_5_19,
    control.cis_v160_5_20,
    control.cis_v160_5_21,
    control.cis_v160_5_22,
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

control "cis_v160_5_2" {
  title         = "5.2 Ensure that, if applicable, an AppArmor Profile is enabled"
  description   = "AppArmor is an effective and easy-to-use Linux application security system. It is
available on some Linux distributions by default, for example, on Debian and Ubuntu."
  query         = query.container_apparmor_profile_enabled
  documentation = file("./cis_v160/docs/cis_v160_1_1.md")

  tags = merge(local.cis_v160_1_common_tags, {
    cis_item_id = "5.2"
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

control "cis_v160_5_10" {
  title         = "5.10 Ensure that the host's network namespace is not shared"
  description   = "When the networking mode on a container is set to --net=host, the container is not
placed inside a separate network stack. Effectively, applying this option instructs Docker
to not containerize the container's networking. The consequence of this is that the
container lives outside in the main Docker host and has full access to its network
interfaces."
  query         = query.contianer_host_network_namespace_shared
  documentation = file("./cis_v160/docs/cis_v160_1_1.md")

  tags = merge(local.cis_v160_1_common_tags, {
    cis_item_id = "5.10"
    cis_level   = "5"
    cis_type    = "manual"
    service     = "Docker"
  })
}

control "cis_v160_5_11" {
  title         = "5.11 Ensure that the memory usage for containers is limited"
  description   = "By default, all containers on a Docker host share resources equally. By using the
resource management capabilities of the Docker host, you can control the amount of
memory that a container is able to use."
  query         = query.contianer_memory_usage_limit
  documentation = file("./cis_v160/docs/cis_v160_1_1.md")

  tags = merge(local.cis_v160_1_common_tags, {
    cis_item_id = "5.11"
    cis_level   = "5"
    cis_type    = "manual"
    service     = "Docker"
  })
}

control "cis_v160_5_12" {
  title         = "5.12 Ensure that CPU priority is set appropriately on containers"
  description   = "By default, all containers on a Docker host share resources equally. By using the
resource management capabilities of the Docker host you can control the host CPU
resources that a container may consume."
  query         = query.contianer_cpu_priority_set
  documentation = file("./cis_v160/docs/cis_v160_1_1.md")

  tags = merge(local.cis_v160_1_common_tags, {
    cis_item_id = "5.12"
    cis_level   = "5"
    cis_type    = "manual"
    service     = "Docker"
  })
}

control "cis_v160_5_13" {
  title         = "5.13 Ensure that the container's root filesystem is mounted as read only"
  description   = "The container's root filesystem should be treated as a 'golden image' by using Docker
run's --read-only option. This prevents any writes to the container's root filesystem at
container runtime and enforces the principle of immutable infrastructure."
  query         = query.contianer_root_filesystem_mounted
  documentation = file("./cis_v160/docs/cis_v160_1_1.md")

  tags = merge(local.cis_v160_1_common_tags, {
    cis_item_id = "5.13"
    cis_level   = "5"
    cis_type    = "manual"
    service     = "Docker"
  })
}

control "cis_v160_5_15" {
  title         = "5.15 Ensure that the 'on-failure' container restart policy is set to '5'"
  description   = "By using the --restart flag in the docker run command you can specify a restart policy
for how a container should or should not be restarted on exit. You should choose the
on-failure restart policy and limit the restart attempts to 5."
  query         = query.contianer_restart_policy_on_failure
  documentation = file("./cis_v160/docs/cis_v160_1_1.md")

  tags = merge(local.cis_v160_1_common_tags, {
    cis_item_id = "5.15"
    cis_level   = "5"
    cis_type    = "manual"
    service     = "Docker"
  })
}

control "cis_v160_5_16" {
  title         = "5.16 Ensure that the host's process namespace is not shared"
  description   = "The Process ID (PID) namespace isolates the process ID space, meaning that
processes in different PID namespaces can have the same PID. This creates process
level isolation between the containers and the host."
  query         = query.contianer_host_process_namespace_shared
  documentation = file("./cis_v160/docs/cis_v160_1_1.md")

  tags = merge(local.cis_v160_1_common_tags, {
    cis_item_id = "5.16"
    cis_level   = "5"
    cis_type    = "manual"
    service     = "Docker"
  })
}

control "cis_v160_5_17" {
  title         = "5.17 Ensure that the host's IPC namespace is not shared"
  description   = "IPC (POSIX/SysV IPC) namespace provides separation of named shared memory
segments, semaphores and message queues. The IPC namespace on the host should
therefore not be shared with containers and should remain isolated."
  query         = query.contianer_host_ipc_namespace_shared
  documentation = file("./cis_v160/docs/cis_v160_1_1.md")

  tags = merge(local.cis_v160_1_common_tags, {
    cis_item_id = "5.17"
    cis_level   = "5"
    cis_type    = "manual"
    service     = "Docker"
  })
}

control "cis_v160_5_18" {
  title         = "5.18 Ensure that host devices are not directly exposed to containers"
  description   = "Host devices can be directly exposed to containers at runtime. Do not directly expose
host devices to containers, especially to containers that are not trusted."
  query         = query.host_devices_exposed_to_containers
  documentation = file("./cis_v160/docs/cis_v160_1_1.md")

  tags = merge(local.cis_v160_1_common_tags, {
    cis_item_id = "5.18"
    cis_level   = "5"
    cis_type    = "manual"
    service     = "Docker"
  })
}

control "cis_v160_5_19" {
  title         = "5.19 Ensure that the default ulimit is overwritten at runtime if needed"
  description   = "The default ulimit is set at the Docker daemon level. However, if you need to, you may
override the default ulimit setting during container runtime."
  query         = query.container_default_ulimit
  documentation = file("./cis_v160/docs/cis_v160_1_1.md")

  tags = merge(local.cis_v160_1_common_tags, {
    cis_item_id = "5.19"
    cis_level   = "5"
    cis_type    = "manual"
    service     = "Docker"
  })
}

control "cis_v160_5_20" {
  title         = "5.20 Ensure mount propagation mode is not set to shared"
  description   = "Mount propagation mode allows mounting volumes in shared, slave or private mode on
a container. Do not use shared mount propagation mode unless explicitly needed."
  query         = query.container_mount_propagation_mode_shared
  documentation = file("./cis_v160/docs/cis_v160_1_1.md")

  tags = merge(local.cis_v160_1_common_tags, {
    cis_item_id = "5.20"
    cis_level   = "5"
    cis_type    = "manual"
    service     = "Docker"
  })
}

control "cis_v160_5_21" {
  title         = "5.21 Ensure that the host's UTS namespace is not shared"
  description   = "UTS namespaces provide isolation between two system identifiers: the hostname and
the NIS domain name. It is used to set the hostname and the domain which are visible
to running processes in that namespace. Processes running within containers do not
typically require to know either the hostname or the domain name. The UTS namespace
should therefore not be shared with the host."
  query         = query.contianer_host_uts_namespace_shared
  documentation = file("./cis_v160/docs/cis_v160_1_1.md")

  tags = merge(local.cis_v160_1_common_tags, {
    cis_item_id = "5.21"
    cis_level   = "5"
    cis_type    = "manual"
    service     = "Docker"
  })
}

control "cis_v160_5_22" {
  title         = "5.22 Ensure the default seccomp profile is not Disabled"
  description   = "Seccomp filtering provides a means for a process to specify a filter for incoming system
calls. The default Docker seccomp profile works on a whitelist basis and allows for a
large number of common system calls, whilst blocking all others. This filtering should
not be disabled unless it causes a problem with your container application usage."
  query         = query.contianer_default_seccomp_profile_disabled
  documentation = file("./cis_v160/docs/cis_v160_1_1.md")

  tags = merge(local.cis_v160_1_common_tags, {
    cis_item_id = "5.22"
    cis_level   = "5"
    cis_type    = "manual"
    service     = "Docker"
  })
}