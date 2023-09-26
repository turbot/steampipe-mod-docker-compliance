query "network_traffic_restricted_between_containers" {
  sql = <<-EOQ
    select
      id as resource,
      case
        when options->>'com.docker.network.bridge.enable_icc' = 'false' then 'ok'
        else 'alarm'
      end as status,
      case
        when options->>'com.docker.network.bridge.enable_icc' = 'false' then 'network traffic is restricted between containers on the default bridge.'
        else 'network traffic is not restricted between containers on the default bridge.'
      end as reason
      ${local.common_dimensions_sql}
    from
      docker_network
    where
      name = 'bridge';
  EOQ
}

