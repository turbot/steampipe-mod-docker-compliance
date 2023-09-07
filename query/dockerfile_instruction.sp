query "container_non_root_user" {
  sql = <<-EOQ
    with command_output as (
      select
        output
      from
        exec_command
      where
        command = 'docker ps --quiet | xargs -I{} docker exec {} cat /proc/1/status | grep ''^Uid:'' | awk ''{print $3}'''
    ), hostname as (
      select
        output
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

query "dockerfile_add_instruction" {
  sql = <<-EOQ
    with dockerfile_user as (
      select
        distinct path
      from
        dockerfile_instruction
      where
        instruction = 'add'
    )select
      distinct i.path as resource,
      case
        when u.path is null then 'ok'
        else 'alarm'
      end as status,
      case
        when u.path is null then 'Dockerfile does not contains the add instruction.'
        else 'Dockerfile does contains the add instruction.'
      end as reason
    from
      dockerfile_instruction as i
      left join dockerfile_user as u
      on i.path = u.path;
  EOQ
}


