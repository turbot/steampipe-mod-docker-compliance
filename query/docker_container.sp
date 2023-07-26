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
