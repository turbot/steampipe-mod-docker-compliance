query "separate_partition_for_containers_created" {
  sql = <<-EOQ
    with command_output as (
    select
      output
    from
      exec_command
    where
      command = E'mountpoint -- "$(docker info -f \'{{ .DockerRootDir }}\')"'
    )select
      id as resource,
      case
        when output like '%not a mountpoint%' then 'alarm'
        else 'ok'
      end as status,
      case
        when output like '%not a mountpoint%' then name || ' configured root directory is not a mount point.'
        else name || ' configured root directory is a mount point.'
      end as reason
    from
      docker_info,
      command_output;
  EOQ
}

query "docker_daemon_run_as_root_user" {
  sql = <<-EOQ
    with command_output as (
    select
      output
    from
      exec_command
    where
      command = 'ps -fe | grep ''dockerd'''
    )select
      id as resource,
      case
        when output like '%root%' then 'alarm'
        else 'ok'
      end as status,
      case
        when output like '%root%' then name || ' docker daemon is running as root user.'
        else name || ' docker daemon is not running as root user.'
      end as reason
    from
      docker_info,
      command_output;
  EOQ
}

query "logging_level_set_to_info" {
  sql = <<-EOQ
    with command_output as (
    select
      output
    from
      exec_command
    where
      command = 'ps -fe | grep ''dockerd'''
    )select
      id as resource,
      case
        when output like '%--log-level=info%'
        or output not like '%--log-level%' then 'ok'
        else 'alarm'
      end as status,
      case
        when output like '%--log-level=info%'
        or output not like '%--log-level%' then name || ' logging level is not set or set to info.'
        else name || ' logging level is not set to info.'
      end as reason
    from
      docker_info,
      command_output;
  EOQ
}

query "docker_daemon_auditing_configured" {
  sql = <<-EOQ
    with command_output as (
    select
      output
    from
      exec_command
    where
      command = 'sudo auditctl -l | grep /usr/bin/dockerd'
    )select
      id as resource,
      case
        when output = '' then 'alarm'
        else 'ok'
      end as status,
      case
        when output = '' then name || ' docker daemon auditing is not configured.'
        else name || ' docker daemon auditing is configured.'
      end as reason
    from
      docker_info,
      command_output;
  EOQ
}

query "docker_socket_file_ownership_set_to_root" {
  sql = <<-EOQ
    with command_output as (
    select
      output
    from
      exec_command
    where
      command = 'stat -c %U:%G "$(systemctl show -p FragmentPath docker.socket | awk -F''='' ''{print $2}'')" | grep -v root:root'
    ),file_location as (
    select
      output
    from
      exec_command
    where
      command = 'systemctl show -p FragmentPath docker.socket'
    )select
      id as resource,
      case
        when l.output = '' then 'skip'
        when o.output = '' then 'ok'
        else 'alarm'
      end as status,
      case
        when l.output = '' then name || ' recommendation is not applicable as the file is unavailable.'
        when o.output = '' then name || ' file ownership is set to root:root.'
        else name || ' docker daemon auditing is configured.'
      end as reason
    from
      docker_info,
      command_output as o,
      file_location as l;
  EOQ
}

query "etc_docker_directory_ownership_set_to_root" {
  sql = <<-EOQ
    with command_output as (
    select
      output
    from
      exec_command
    where
      command = 'stat -c %U:%G "$(systemctl show -p FragmentPath docker.socket | awk -F''='' ''{print $2}'')" | grep -v root:root'
    )select
      id as resource,
      case
        when o.output = '' then 'ok'
        else 'alarm'
      end as status,
      case
        when o.output = '' then name || ' /etc/docker directory ownership is set to root:root.'
        else name || ' /etc/docker directory ownership is not set to root:root.'
      end as reason
    from
      docker_info,
      command_output as o;
  EOQ
}