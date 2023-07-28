query "container_healthcheck_instruction" {
  sql = <<-EOQ
    select
      id as resource,
      case
        when config -> 'Healthcheck' is null then 'alarm'
        else 'ok'
      end as status,
      case
        when config -> 'Healthcheck' is null then names::text || ' do not have a health check configured.'
        else names::text || ' have a health check configured.'
      end as reason
    from
      docker_container;
  EOQ
}

query "container_apparmor_profile_enabled" {
  sql = <<-EOQ
    select
      id as resource,
      case
        when inspect ->> 'AppArmorProfile' = '' then 'alarm'
        else 'ok'
      end as status,
      case
        when inspect ->> 'AppArmorProfile' = '' then names::text || ' do not have a AppArmor profile configured.'
        else names::text || ' have a AppArmor profile configured.'
      end as reason
    from
      docker_container;
  EOQ
}

query "contianer_host_network_namespace_shared" {
  sql = <<-EOQ
    select
      id as resource,
      case
        when inspect -> 'HostConfig' ->> 'NetworkMode' = 'host' then 'alarm'
        else 'ok'
      end as status,
      case
        when inspect -> 'HostConfig' ->> 'NetworkMode' = 'host' then names::text || ' host network namespace is shared.'
        else names::text || ' host network namespace is not shared.'
      end as reason
    from
      docker_container;
  EOQ
}

query "contianer_memory_usage_limit" {
  sql = <<-EOQ
    select
      id as resource,
      case
        when inspect -> 'HostConfig' ->> 'Memory' = '0' then 'alarm'
        else 'ok'
      end as status,
      case
        when inspect -> 'HostConfig' ->> 'Memory' = '0' then names::text || ' memory usage is not limited.'
        else names::text || ' memory usage is limited.'
      end as reason
    from
      docker_container;
  EOQ
}

query "contianer_cpu_priority_set" {
  sql = <<-EOQ
    select
      id as resource,
      case
        when inspect -> 'HostConfig' ->> 'CpuShares' in ('0','1024') then 'alarm'
        else 'ok'
      end as status,
      case
        when inspect -> 'HostConfig' ->> 'CpuShares' in ('0','1024') then names::text || ' CPU priority is not set appropriately.'
        else names::text || ' CPU priority is set appropriately.'
      end as reason
    from
      docker_container;
  EOQ
}

query "contianer_root_filesystem_mounted" {
  sql = <<-EOQ
    select
      id as resource,
      case
        when inspect -> 'HostConfig' ->> 'ReadonlyRootfs' = 'false' then 'alarm'
        else 'ok'
      end as status,
      case
        when inspect -> 'HostConfig' ->> 'ReadonlyRootfs' = 'false' then names::text || ' root filesystem is not mounted as read only.'
        else names::text || ' root filesystem is mounted as read only.'
      end as reason
    from
      docker_container;
  EOQ
}

query "contianer_restart_policy_on_failure" {
  sql = <<-EOQ
    select
      id as resource,
      case
        when inspect -> 'HostConfig' -> 'RestartPolicy' ->> 'Name' = 'on-failure'
        and inspect -> 'HostConfig' -> 'RestartPolicy' ->> 'MaximumRetryCount' = '5' then 'ok'
        else 'alarm'
      end as status,
      case
        when inspect -> 'HostConfig' ->> 'ReadonlyRootfs' = 'false' then names::text || ' RestartPolicy is set to on-failure with MaximumRetryCount 5.'
        else names::text || ' RestartPolicy is not set to on-failure with MaximumRetryCount 5.'
      end as reason
    from
      docker_container;
  EOQ
}

query "contianer_host_process_namespace_shared" {
  sql = <<-EOQ
    select
      id as resource,
      case
        when inspect -> 'HostConfig' ->> 'PidMode' = 'host' then 'alarm'
        else 'ok'
      end as status,
      case
        when inspect -> 'HostConfig' ->> 'PidMode' = 'host' then names::text || ' host PID namespace is shared.'
        else names::text || ' host PID namespace is not shared.'
      end as reason
    from
      docker_container;
  EOQ
}

query "contianer_host_ipc_namespace_shared" {
  sql = <<-EOQ
    select
      id as resource,
      case
        when inspect -> 'HostConfig' ->> 'IpcMode' = 'host' then 'alarm'
        else 'ok'
      end as status,
      case
        when inspect -> 'HostConfig' ->> 'IpcMode' = 'host' then names::text || ' host IPC namespace is shared.'
        else names::text || ' host IPC namespace is not shared.'
      end as reason
    from
      docker_container;
  EOQ
}

query "host_devices_exposed_to_containers" {
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
        or inspect -> 'HostConfig' ->> 'Devices' is null then names::text || ' host devices not exposed.'
        else names::text || ' host devices exposed.'
      end as reason
    from
      docker_container;
  EOQ
}

query "container_default_ulimit" {
  sql = <<-EOQ
    select
      id as resource,
      case
        when inspect -> 'HostConfig' ->> 'Ulimits' is null then 'ok'
        else 'alarm'
      end as status,
      case
        when inspect -> 'HostConfig' ->> 'Ulimits' is null then names::text || ' default ulimit is not overwritten.'
        else names::text || ' default ulimit is overwritten.'
      end as reason
    from
      docker_container;
  EOQ
}

query "container_mount_propagation_mode_shared" {
  sql = <<-EOQ
    select
      distinct c.id as resource,
      case
        when m.id is null then 'ok'
        else 'alarm'
      end as status,
      case
        when m.id is null then names::text || ' mount propagation mode is not shared.'
        else names::text || ' mount propagation mode is shared.'
      end as reason
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

query "contianer_host_uts_namespace_shared" {
  sql = <<-EOQ
    select
      id as resource,
      case
        when inspect -> 'HostConfig' ->> 'UTSMode' = 'host' then 'alarm'
        else 'ok'
      end as status,
      case
        when inspect -> 'HostConfig' ->> 'UTSMode' = 'host' then names::text || ' host UTS namespace is shared.'
        else names::text || ' host UTS namespace is not shared.'
      end as reason
    from
      docker_container;
  EOQ
}

query "contianer_default_seccomp_profile_disabled" {
  sql = <<-EOQ
    select
      id as resource,
      case
        when inspect->'HostConfig'->'SecurityOpt' @> '["seccomp=unconfined"]' then 'alarm'
        else 'ok'
      end as status,
      case
        when inspect->'HostConfig'->'SecurityOpt' @> '["seccomp=unconfined"]' then names::text || ' default seccomp profile is disabled.'
        else names::text || ' default seccomp profile is not disabled.'
      end as reason
    from
      docker_container;
  EOQ
}

query "contianer_cgroup_usage" {
  sql = <<-EOQ
    select
      id as resource,
      case
        when inspect -> 'HostConfig' ->> 'CgroupParent' = '' then 'ok'
        else 'alarm'
      end as status,
      case
        when inspect -> 'HostConfig' ->> 'CgroupParent' = '' then names::text || ' are not running under the default docker cgroup.'
        else names::text || ' are running under the default docker cgroup.'
      end as reason
    from
      docker_container;
  EOQ
}

query "contianer_no_new_privileges" {
  sql = <<-EOQ
    select
      id as resource,
      case
        when inspect->'HostConfig'->'SecurityOpt' @> '["no-new-privileges=false"]' then 'alarm'
        else 'ok'
      end as status,
      case
        when inspect->'HostConfig'->'SecurityOpt' @> '["no-new-privileges=false"]' then names::text || ' new privileges are not restricted.'
        else names::text || ' new privileges are restricted.'
      end as reason
    from
      docker_container;
  EOQ
}

query "contianer_pid_cgroup_limit_used" {
  sql = <<-EOQ
    select
      id as resource,
      case
        when inspect -> 'HostConfig' ->> 'PidsLimit' in ('0','-1') then 'alarm'
        else 'ok'
      end as status,
      case
        when inspect -> 'HostConfig' ->> 'PidsLimit' in ('0','-1') then names::text || ' PIDs cgroup limit is unused.'
        else names::text || ' PIDs cgroup limit is used.'
      end as reason
    from
      docker_container;
  EOQ
}

query "contianer_host_user_namespace_shared" {
  sql = <<-EOQ
    select
      id as resource,
      case
        when inspect -> 'HostConfig' ->> 'UsernsMode' = 'host' then 'alarm'
        else 'ok'
      end as status,
      case
        when inspect -> 'HostConfig' ->> 'UsernsMode' = 'host' then names::text || ' host user namespace is shared.'
        else names::text || ' host user namespace is not shared.'
      end as reason
    from
      docker_container;
  EOQ
}

query "privileged_containers" {
  sql = <<-EOQ
    select
      id as resource,
      case
        when inspect -> 'HostConfig' ->> 'Privileged' = 'true' then 'alarm'
        else 'ok'
      end as status,
      case
        when inspect -> 'HostConfig' ->> 'Privileged' = 'true' then names::text || ' is running as a privileged container.'
        else names::text || ' is not running as a privileged container.'
      end as reason
    from
      docker_container;
  EOQ
}

query "host_system_directories_mounted_on_containers" {
  sql = <<-EOQ
    select
      distinct c.id as resource,
      case
        when m.id is null then 'ok'
        else 'alarm'
      end as status,
      case
        when m.id is null then names::text || ' host system directories are not mounted.'
        else names::text || ' host system directories are mounted.'
      end as reason
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
