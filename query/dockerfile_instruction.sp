query "container_non_root_user" {
  sql = <<-EOQ
    ${local.hostname_sql}
     command_output as (
      select
        output,
         _ctx ->> 'connection' as conn
      from
        exec_command
      where
        command = 'docker ps --quiet | xargs -I{} docker exec {} cat /proc/1/status | grep ''^Uid:'' | awk ''{print $3}'''
    )
    select
      host as resource,
      case
        when o.output like '%0%' then 'alarm'
        else 'ok'
      end as status,
      host || case
        when o.output like '%0%' then host || ' container process is running as root user.'
        else host || ' container process is not running as root user.'
      end as reason
    from
      hostname as h,
      command_output as o
    where
      host_conn = o.conn;
  EOQ
}


