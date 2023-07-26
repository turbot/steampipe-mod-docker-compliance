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
