query "docker_container_healthcheck_instruction" {
  sql = <<-EOQ
    select
      id as resource,
      case
        when config -> 'Healthcheck' is null then 'alarm'
        else 'ok'
      end as status,
      (names ->> 0) || case
        when config -> 'Healthcheck' is null then ' health check configured.'
        else ' health check not configured.'
      end as reason
      ${local.common_dimensions_sql}
    from
      docker_container;
  EOQ
}

query "docker_container_apparmor_profile_enabled" {
  sql = <<-EOQ
    select
      id as resource,
      case
        when inspect ->> 'AppArmorProfile' = '' then 'alarm'
        else 'ok'
      end as status,
      case
        when inspect ->> 'AppArmorProfile' = '' then (names ->> 0) || ' AppArmor profile configured.'
        else (names ->> 0) || ' AppArmor profile not configured.'
      end as reason
      ${local.common_dimensions_sql}
    from
      docker_container;
  EOQ
}

query "docker_container_host_network_namespace_shared" {
  sql = <<-EOQ
    select
      id as resource,
      case
        when inspect -> 'HostConfig' ->> 'NetworkMode' = 'host' then 'alarm'
        else 'ok'
      end as status,
      case
        when inspect -> 'HostConfig' ->> 'NetworkMode' = 'host' then (names ->> 0) || ' host network namespace shared.'
        else (names ->> 0) || ' host network namespace not shared.'
      end as reason
      ${local.common_dimensions_sql}
    from
      docker_container;
  EOQ
}

query "docker_container_memory_usage_limit" {
  sql = <<-EOQ
    select
      id as resource,
      case
        when inspect -> 'HostConfig' ->> 'Memory' = '0' then 'alarm'
        else 'ok'
      end as status,
      case
        when inspect -> 'HostConfig' ->> 'Memory' = '0' then (names ->> 0) || ' memory usage not limited.'
        else (names ->> 0) || ' memory usage limited.'
      end as reason
      ${local.common_dimensions_sql}
    from
      docker_container;
  EOQ
}

query "docker_container_cpu_priority_set" {
  sql = <<-EOQ
    select
      id as resource,
      case
        when inspect -> 'HostConfig' ->> 'CpuShares' in ('0','1024') then 'alarm'
        else 'ok'
      end as status,
      case
        when inspect -> 'HostConfig' ->> 'CpuShares' in ('0','1024') then (names ->> 0) || ' CPU priority not set appropriately.'
        else (names ->> 0) || ' CPU priority set appropriately.'
      end as reason
      ${local.common_dimensions_sql}
    from
      docker_container;
  EOQ
}

query "docker_container_root_filesystem_mounted" {
  sql = <<-EOQ
    select
      id as resource,
      case
        when inspect -> 'HostConfig' ->> 'ReadonlyRootfs' = 'false' then 'alarm'
        else 'ok'
      end as status,
      case
        when inspect -> 'HostConfig' ->> 'ReadonlyRootfs' = 'false' then (names ->> 0) || ' root filesystem not mounted as read only.'
        else (names ->> 0) || ' root filesystem mounted as read only.'
      end as reason
      ${local.common_dimensions_sql}
    from
      docker_container;
  EOQ
}

query "docker_container_restart_policy_on_failure" {
  sql = <<-EOQ
    select
      id as resource,
      case
        when inspect -> 'HostConfig' -> 'RestartPolicy' ->> 'Name' = 'on-failure'
        and inspect -> 'HostConfig' -> 'RestartPolicy' ->> 'MaximumRetryCount' = '5' then 'ok'
        else 'alarm'
      end as status,
      case
        when inspect -> 'HostConfig' ->> 'ReadonlyRootfs' = 'false' then (names ->> 0) || ' RestartPolicy set to on-failure with MaximumRetryCount 5.'
        else (names ->> 0) || ' RestartPolicy not set to on-failure with MaximumRetryCount 5.'
      end as reason
      ${local.common_dimensions_sql}
    from
      docker_container;
  EOQ
}

query "docker_container_host_process_namespace_shared" {
  sql = <<-EOQ
    select
      id as resource,
      case
        when inspect -> 'HostConfig' ->> 'PidMode' = 'host' then 'alarm'
        else 'ok'
      end as status,
      case
        when inspect -> 'HostConfig' ->> 'PidMode' = 'host' then (names ->> 0) || ' host PID namespace shared.'
        else (names ->> 0) || ' host PID namespace not shared.'
      end as reason
      ${local.common_dimensions_sql}
    from
      docker_container;
  EOQ
}

query "docker_container_host_ipc_namespace_shared" {
  sql = <<-EOQ
    select
      id as resource,
      case
        when inspect -> 'HostConfig' ->> 'IpcMode' = 'host' then 'alarm'
        else 'ok'
      end as status,
      case
        when inspect -> 'HostConfig' ->> 'IpcMode' = 'host' then (names ->> 0) || ' host IPC namespace shared.'
        else (names ->> 0) || ' host IPC namespace not shared.'
      end as reason
      ${local.common_dimensions_sql}
    from
      docker_container;
  EOQ
}

query "docker_container_host_devices_exposed" {
  sql = <<-EOQ
    select
      id as resource,
      case
        when inspect -> 'HostConfig' -> 'Devices' = '[]'
        or inspect -> 'HostConfig' ->> 'Devices' is null then 'ok'
        else 'alarm'
      end as status,
      case
        when inspect -> 'HostConfig' -> 'Devices' = '[]'
        or inspect -> 'HostConfig' ->> 'Devices' is null then (names ->> 0) || ' host devices not exposed.'
        else (names ->> 0) || ' host devices exposed.'
      end as reason
      ${local.common_dimensions_sql}
    from
      docker_container;
  EOQ
}

query "docker_container_default_ulimit" {
  sql = <<-EOQ
    select
      id as resource,
      case
        when inspect -> 'HostConfig' ->> 'Ulimits' is null then 'ok'
        else 'alarm'
      end as status,
      case
        when inspect -> 'HostConfig' ->> 'Ulimits' is null then (names ->> 0) || ' default ulimit not overwritten.'
        else (names ->> 0) || ' default ulimit overwritten.'
      end as reason
      ${local.common_dimensions_sql}
    from
      docker_container;
  EOQ
}

query "docker_container_mount_propagation_mode_shared" {
  sql = <<-EOQ
    select
      distinct c.id as resource,
      case
        when m.id is null then 'ok'
        else 'alarm'
      end as status,
      case
        when m.id is null then (names ->> 0) || ' mount propagation mode not shared.'
        else (names ->> 0) || ' mount propagation mode shared.'
      end as reason
      ${local.common_dimensions_sql}
    from
      docker_container as c
      left join (
        select distinct id
        from docker_container,
            jsonb_array_elements(mounts) as m
        where m ->> 'Propagation' = 'shared'
      ) as m on c.id = m.id;
  EOQ
}

query "docker_container_host_uts_namespace_shared" {
  sql = <<-EOQ
    select
      id as resource,
      case
        when inspect -> 'HostConfig' ->> 'UTSMode' = 'host' then 'alarm'
        else 'ok'
      end as status,
      case
        when inspect -> 'HostConfig' ->> 'UTSMode' = 'host' then (names ->> 0) || ' host UTS namespace shared.'
        else (names ->> 0) || ' host UTS namespace not shared.'
      end as reason
      ${local.common_dimensions_sql}
    from
      docker_container;
  EOQ
}

query "docker_container_default_seccomp_profile_disabled" {
  sql = <<-EOQ
    select
      id as resource,
      case
        when inspect->'HostConfig'->'SecurityOpt' @> '["seccomp=unconfined"]' then 'alarm'
        else 'ok'
      end as status,
      case
        when inspect->'HostConfig'->'SecurityOpt' @> '["seccomp=unconfined"]' then (names ->> 0) || ' default seccomp profile disabled.'
        else (names ->> 0) || ' default seccomp profile not disabled.'
      end as reason
      ${local.common_dimensions_sql}
    from
      docker_container;
  EOQ
}

query "docker_container_cgroup_usage" {
  sql = <<-EOQ
    select
      id as resource,
      case
        when inspect -> 'HostConfig' ->> 'CgroupParent' = '' then 'ok'
        else 'alarm'
      end as status,
      case
        when inspect -> 'HostConfig' ->> 'CgroupParent' = '' then (names ->> 0) || ' are not running under the default Docker cgroup.'
        else (names ->> 0) || ' are running under the default Docker cgroup.'
      end as reason
      ${local.common_dimensions_sql}
    from
      docker_container;
  EOQ
}

query "docker_container_no_new_privileges" {
  sql = <<-EOQ
    select
      id as resource,
      case
        when inspect->'HostConfig'->'SecurityOpt' @> '["no-new-privileges=false"]' then 'alarm'
        else 'ok'
      end as status,
      case
        when inspect->'HostConfig'->'SecurityOpt' @> '["no-new-privileges=false"]' then (names ->> 0) || ' new privileges are not restricted.'
        else (names ->> 0) || ' new privileges are restricted.'
      end as reason
      ${local.common_dimensions_sql}
    from
      docker_container;
  EOQ
}

query "docker_container_pid_cgroup_limit_used" {
  sql = <<-EOQ
    select
      id as resource,
      case
        when inspect -> 'HostConfig' ->> 'PidsLimit' in ('0','-1') then 'alarm'
        else 'ok'
      end as status,
      case
        when inspect -> 'HostConfig' ->> 'PidsLimit' in ('0','-1') then (names ->> 0) || ' PIDs cgroup limit unused.'
        else (names ->> 0) || ' PIDs cgroup limit used.'
      end as reason
      ${local.common_dimensions_sql}
    from
      docker_container;
  EOQ
}

query "docker_container_host_user_namespace_shared" {
  sql = <<-EOQ
    select
      id as resource,
      case
        when inspect -> 'HostConfig' ->> 'UsernsMode' = 'host' then 'alarm'
        else 'ok'
      end as status,
      case
        when inspect -> 'HostConfig' ->> 'UsernsMode' = 'host' then (names ->> 0) || ' host user namespace shared.'
        else (names ->> 0) || ' host user namespace not shared.'
      end as reason
      ${local.common_dimensions_sql}
    from
      docker_container;
  EOQ
}

query "docker_container_privileged" {
  sql = <<-EOQ
    select
      id as resource,
      case
        when inspect -> 'HostConfig' ->> 'Privileged' = 'true' then 'alarm'
        else 'ok'
      end as status,
      case
        when inspect -> 'HostConfig' ->> 'Privileged' = 'true' then (names ->> 0) || ' running as a privileged container.'
        else (names ->> 0) || ' running as a privileged container.'
      end as reason
      ${local.common_dimensions_sql}
    from
      docker_container;
  EOQ
}

query "docker_container_host_system_directories_mounted" {
  sql = <<-EOQ
    select
      distinct c.id as resource,
      case
        when m.id is null then 'ok'
        else 'alarm'
      end as status,
      case
        when m.id is null then (names ->> 0) || ' host system directories are not mounted.'
        else (names ->> 0) || ' host system directories are mounted.'
      end as reason
      ${local.common_dimensions_sql}
    from
      docker_container as c
      left join (
        select distinct id
        from docker_container,
            jsonb_array_elements(mounts) as m
        where m ->> 'Destination' in ('/', '/var', '/boot', '/dev', '/etc', '/lib', '/proc', '/sys', '/usr')
          and m ->> 'RW' = 'true'
      ) as m on c.id = m.id;
  EOQ
}
