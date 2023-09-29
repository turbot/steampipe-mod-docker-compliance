query "docker_network_traffic_restricted_between_containers" {
  sql = <<-EOQ
    select
      id as resource,
      case
        when name != 'bridge' then 'skip'
        when options->>'com.docker.network.bridge.enable_icc' = 'false' then 'ok'
        else 'alarm'
      end as status,
      name || case
        when name != 'bridge' then ' is not default bridge network.'
        when options ->> 'com.docker.network.bridge.enable_icc' = 'false' then ' has network traffic restricted between containers.'
        else ' does not have network traffic restricted between containers.'
      end as reason
      ${local.common_dimensions_sql}
    from
      docker_network
    where
      name = 'bridge';
  EOQ
}

