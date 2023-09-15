query "container_non_root_user" {
  sql = <<-EOQ
    with command_output as (
      select
        btrim(output, E' \n\r\t') as output
      from
        exec_command
      where
        command = 'docker ps --quiet | xargs -I{} docker exec {} cat /proc/1/status | grep ''^Uid:'' | awk ''{print $3}'''
    ), hostname as (
      select
        btrim(output, E' \n\r\t') as output
      from
        exec_command
      where
        command = 'hostname'
    )
    select
      h.output as resource,
      case
        when o.output like '%0%' then 'alarm'
        else 'ok'
      end as status,
      h.output || case
        when o.output like '%0%' then ' container process is running as root user.'
        else 'Container process is not running as root user.'
      end as reason
    from
      hostname as h,
      command_output as o;
  EOQ
}


