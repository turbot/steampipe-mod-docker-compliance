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