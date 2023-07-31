query "swarm_mode_enabled" {
  sql = <<-EOQ
    select
      id as resource,
      case
        when swarm ->> 'LocalNodeState' = 'inactive' then 'ok'
        else 'alarm'
      end as status,
      case
        when swarm ->> 'LocalNodeState' = 'inactive' then name || ' swarm mode is disabled.'
        else name || ' swarm mode is enabled.'
      end as reason
    from
      docker_info;
  EOQ
}

query "container_sprawl_avoided" {
  sql = <<-EOQ
    select
      id as resource,
      case
        when containers_stopped > containers_running then 'alarm'
        else 'ok'
      end as status,
      case
        when containers_stopped > containers_running then name || ' suffering from container sprawl.'
        else name || ' suffering from container sprawl.'
      end as reason
    from
      docker_info;
  EOQ
}

query "swarm_minimum_required_manager_nodes" {
  sql = <<-EOQ
    select
      id as resource,
      case
        when (swarm ->> 'Managers')::int > 0 then 'ok'
        else 'alarm'
      end as status,
      case
        when (swarm ->> 'Managers')::int > 0 then name || ' minimum number of manager nodes have not been created.'
        else name || ' minimum number of manager nodes have been created.'
      end as reason
    from
      docker_info;
  EOQ
}

query "swarm_manager_auto_lock_mode" {
  sql = <<-EOQ
    select
      id as resource,
      case
        when swarm -> 'Cluster' -> 'Spec' -> 'EncryptionConfig' ->> 'AutoLockManagers' = 'true' then 'ok'
        else 'alarm'
      end as status,
      case
        when swarm -> 'Cluster' -> 'Spec' -> 'EncryptionConfig' ->> 'AutoLockManagers' = 'true' then name || ' swarm manager is run in auto-lock mode.'
        else name || ' swarm manager is not run in auto-lock mode.'
      end as reason
    from
      docker_info;
  EOQ
}

query "swarm_node_cert_expiry_set" {
  sql = <<-EOQ
    select
      id as resource,
      case
        when swarm -> 'Cluster' -> 'Spec' -> 'CaConfig' ->> 'NodeCertExpiry' is null then 'alarm'
        else 'ok'
      end as status,
      case
        when swarm -> 'Cluster' -> 'Spec' -> 'CaConfig' ->> 'NodeCertExpiry' is null then name || ' node cert expiry is not set.'
        else name || ' node cert expiry is set.'
      end as reason
    from
      docker_info;
  EOQ
}

query "aufs_storage_driver_unused" {
  sql = <<-EOQ
    select
      id as resource,
      case
        when driver = 'aufs' then 'alarm'
        else 'ok'
      end as status,
      case
        when driver = 'aufs' then name || ' aufs storage driver is in use.'
        else name || ' aufs storage driver not in use.'
      end as reason
    from
      docker_info;
  EOQ
}

query "insecure_registries_unused" {
  sql = <<-EOQ
    select
      id as resource,
      case
        when registry_config -> 'InsecureRegistryCIDRs' is null
        or registry_config -> 'InsecureRegistryCIDRs' = '[]' then 'ok'
        else 'alarm'
      end as status,
      case
        when registry_config -> 'InsecureRegistryCIDRs' is null
        or registry_config -> 'InsecureRegistryCIDRs' = '[]' then name || ' insecure registries not in use.'
        else name || ' insecure registries are in use.'
      end as reason
    from
      docker_info;
  EOQ
}

query "user_namespace_support_enabled" {
  sql = <<-EOQ
    select
      id as resource,
      case
         when exists (
           select 1
           from jsonb_array_elements(security_options) AS elem
           where elem @> '"name=userns"'
         ) then 'ok'
         else 'alarm'
      end as status,
      case
        when exists (
           select 1
           from jsonb_array_elements(security_options) AS elem
           where elem @> '"name=userns"'
         ) then name || ' user namespace support is enabled.'
        else name || ' user namespace support is disabled.'
      end as reason
    from
      docker_info;
  EOQ
}

query "centralized_and_remote_logging_configured" {
  sql = <<-EOQ
    select
      id as resource,
      case
        when logging_driver is null then 'alarm'
        else 'ok'
      end as status,
      case
        when logging_driver is null then name || ' centralized and remote logging is not configured.'
        else name || ' centralized and remote logging is configured.'
      end as reason
    from
      docker_info;
  EOQ
}

query "live_restore_enabled" {
  sql = <<-EOQ
    select
      id as resource,
      case
        when live_restore_enabled then 'ok'
        else 'alarm'
      end as status,
      case
        when live_restore_enabled then name || ' live restore is enabled.'
        else name || ' live restore is disabled.'
      end as reason
    from
      docker_info;
  EOQ
}

query "custom_seccomp_profile_applied" {
  sql = <<-EOQ
    select
      id as resource,
      case
         when exists (
           select 1
           from jsonb_array_elements(security_options) AS elem
           where elem @> '"name=seccomp,profile=default"'
         ) then 'alarm'
         else 'ok'
      end as status,
      case
        when exists (
           select 1
           from jsonb_array_elements(security_options) AS elem
           where elem @> '"name=seccomp,profile=default"'
         ) then name || ' default seccomp profile is applied.'
        else name || ' custom seccomp profile is applied.'
      end as reason
    from
      docker_info;
  EOQ
}
