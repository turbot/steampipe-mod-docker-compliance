query "separate_partition_for_containers_created" {
  sql = <<-EOQ
    with os_output as (
      select
        output
      from
        exec_command
      where
        command = 'uname -s'
    ), hostname as (
      select
        output
      from
        exec_command
      where
        command = 'hostname'
    ), command_output as (
      select
        case
          when os_output.output ilike '%Darwin%' then 'not linux'
          else (select output from exec_command where command = E'mountpoint -- "$(docker info -f \'{{ .DockerRootDir }}\')"')
        end as output
      from
        os_output
    )
    select
      h.output as resource,
      case
        when o.output ilike '%not linux%' then 'skip'
        when o.output like '%not a mountpoint%' then 'alarm'
        else 'ok'
      end as status,
      case
        when o.output ilike '%not linux%'  then ' This is not linux OS.'
        when o.output like '%not a mountpoint%' then h.output || ' configured root directory is not a mount point.'
        else h.output || ' configured root directory is a mount point.'
      end as reason
    from
      hostname as h,
      command_output as o;
  EOQ
}

query "docker_daemon_run_as_root_user" {
  sql = <<-EOQ
    with os_output as (
      select
        output
      from
        exec_command
      where
        command = 'uname -s'
    ), command_output as (
      select
        case
          when os_output.output ilike '%Darwin%' then 'not linux'
          else (select output from exec_command where command = 'ps -fe | grep ''dockerd''')
        end as output
      from
        os_output
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
        when o.output ilike '%not linux%' then 'skip'
        when o.output like '%root%' then 'alarm'
        else 'ok'
      end as status,
      case
        when o.output ilike '%not linux%'  then ' This is not linux OS.'
        when o.output like '%root%' then h.output || ' docker daemon is running as root user.'
        else h.output || ' docker daemon is not running as root user.'
      end as reason
    from
      hostname as h,
      command_output as o;
  EOQ
}

query "logging_level_set_to_info" {
  sql = <<-EOQ
    with os_output as (
      select
        output
      from
        exec_command
      where
        command = 'uname -s'
    ), command_output as (
      select
        case
          when os_output.output ilike '%Darwin%' then 'not linux'
          else (select output from exec_command where command = 'ps -fe | grep ''dockerd''')
        end as output
      from
        os_output
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
        when o.output ilike '%not linux%' then 'skip'
        when o.output like '%--log-level=info%'
        or o.output not like '%--log-level%' then 'ok'
        else 'alarm'
      end as status,
      case
        when o.output ilike '%not linux%'  then ' This is not linux OS.'
        when o.output like '%--log-level=info%'
        or o.output not like '%--log-level%' then h.output || ' logging level is not set or set to info.'
        else h.output || ' logging level is not set to info.'
      end as reason
    from
      hostname as h,
      command_output as o;
  EOQ
}

query "docker_daemon_auditing_configured" {
  sql = <<-EOQ
    with os_output as (
      select
        output
      from
        exec_command
      where
        command = 'uname -s'
    ), command_output as (
      select
        case
          when os_output.output ilike '%Darwin%' then 'not linux'
          else (select output from exec_command where command = 'sudo auditctl -l | grep /usr/bin/dockerd')
        end as output
      from
        os_output
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
        when o.output ilike '%not linux%' then 'skip'
        when o.output = '' then 'alarm'
        else 'ok'
      end as status,
      case
        when o.output ilike '%not linux%' then 'skip'
        when o.output = '' then h.output || ' docker daemon auditing is not configured.'
        else h.output || ' docker daemon auditing is configured.'
      end as reason
    from
      hostname as h,
      command_output as o;
  EOQ
}

query "docker_socket_file_ownership_set_to_root" {
  sql = <<-EOQ
    with os_output as (
      select
        output
      from
        exec_command
      where
        command = 'uname -s'
    ), command_output as (
      select
        case
          when os_output.output ilike '%Darwin%' then 'not linux'
          else (select output from exec_command where command = 'stat -c %U:%G "$(systemctl show -p FragmentPath docker.socket | awk -F''='' ''{print $2}'')" | grep -v root:root')
        end as output
      from
        os_output
    ), file_location as (
        select
          case
            when os_output.output ilike '%Darwin%' then 'not linux'
            else (select output from exec_command where command = 'echo $(systemctl show -p FragmentPath docker.socket)')
          end as output
        from
          os_output
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
         when o.output ilike '%not linux%' then 'skip'
        when l.output = '' then 'skip'
        when o.output = '' then 'ok'
        else 'alarm'
      end as status,
      case
        when o.output ilike '%not linux%'  then ' This is not linux OS.'
        when l.output = '' then h.output || ' recommendation is not applicable as the file is unavailable.'
        when o.output = '' then h.output || ' file ownership is set to root:root.'
        else h.output || ' docker daemon auditing is configured.'
      end as reason
    from
      hostname as h,
      command_output as o,
      file_location as l;
  EOQ
}

query "etc_docker_directory_ownership_set_to_root" {
  sql = <<-EOQ
    with os_output as (
      select
        output
      from
        exec_command
      where
        command = 'uname -s'
    ), command_output as (
      select
        case
          when os_output.output ilike '%Darwin%' then 'not linux'
          else (select output from exec_command where command = 'stat -c %U:%G "$(systemctl show -p FragmentPath docker.socket | awk -F''='' ''{print $2}'')" | grep -v root:root')
        end as output
      from
        os_output
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
        when o.output ilike '%not linux%' then 'skip'
        when o.output = '' then 'ok'
        else 'alarm'
      end as status,
      case
        when o.output ilike '%not linux%'  then ' This is not linux OS.'
        when o.output = '' then h.output || ' /etc/docker directory ownership is set to root:root.'
        else h.output || ' /etc/docker directory ownership is not set to root:root.'
      end as reason
    from
      hostname as h,
      command_output as o;
  EOQ
}

query "docker_files_and_directories_run_containerd_auditing_configured" {
  sql = <<-EOQ
    with os_output as (
      select
        output
      from
        exec_command
      where
        command = 'uname -s'
    ), command_output as (
      select
        case
          when os_output.output ilike '%Darwin%' then 'not linux'
          else (select output from exec_command where command = 'sudo auditctl -l | grep /run/containerd')
        end as output
      from
        os_output
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
        when o.output ilike '%not linux%' then 'skip'
        when o.output = '' then 'alarm'
        else 'ok'
      end as status,
      case
        when o.output ilike '%not linux%'  then ' This is not linux OS.'
        when o.output = '' then h.output || ' docker files and directories "/run/containerd" auditing is not configured.'
        else h.output || ' docker files and directories "/run/containerd" auditing is configured.'
      end as reason
    from
      hostname as h,
      command_output as o;
  EOQ
}

query "docker_files_and_directories_var_lib_docker_auditing_configured" {
  sql = <<-EOQ
    with os_output as (
      select
        output
      from
        exec_command
      where
        command = 'uname -s'
    ), command_output as (
      select
        case
          when os_output.output ilike '%Darwin%' then 'not linux'
          else (select output from exec_command where command = 'sudo auditctl -l | grep /var/lib/docker')
        end as output
      from
        os_output
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
        when o.output ilike '%not linux%' then 'skip'
        when o.output = '' then 'alarm'
        else 'ok'
      end as status,
      case
        when o.output ilike '%not linux%'  then ' This is not linux OS.'
        when o.output = '' then h.output || ' docker files and directories "/var/lib/docker" auditing is not configured.'
        else h.output || ' docker files and directories "/var/lib/docker" auditing is configured.'
      end as reason
    from
      hostname as h,
      command_output as o;
  EOQ
}

query "docker_files_and_directories_etc_docker_auditing_configured" {
  sql = <<-EOQ
    with os_output as (
      select
        output
      from
        exec_command
      where
        command = 'uname -s'
    ), command_output as (
      select
        case
          when os_output.output ilike '%Darwin%' then 'not linux'
          else (select output from exec_command where command = 'sudo auditctl -l | grep /etc/docker')
        end as output
      from
        os_output
    ),hostname as (
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
        when o.output ilike '%not linux%' then 'skip'
        when o.output = '' then 'alarm'
        else 'ok'
      end as status,
      case
        when o.output ilike '%not linux%'  then ' This is not linux OS.'
        when o.output = '' then h.output || ' docker files and directories "/etc/docker" auditing is not configured.'
        else h.output || ' docker files and directories "/etc/docker" auditing is configured.'
      end as reason
    from
      hostname as h,
      command_output as o;
  EOQ
}

query "docker_files_and_directories_docker_service_auditing_configured" {
  sql = <<-EOQ
    with os_output as (
      select
        output
      from
        exec_command
      where
        command = 'uname -s'
    ), command_output as (
      select
        case
          when os_output.output ilike '%Darwin%' then 'not linux'
          else (select output from exec_command where command = 'sudo auditctl -l | grep docker.service')
        end as output
      from
        os_output
    ), file_location as (
        select
          case
            when os_output.output ilike '%Darwin%' then 'not linux'
            else (select output from exec_command where command = 'echo $(systemctl show -p FragmentPath docker.service)')
          end as output
        from
          os_output
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
        when o.output ilike '%not linux%' then 'skip'
        when l.output = '' then 'skip'
        when o.output = '' then 'alarm'
        else 'ok'
      end as status,
      case
        when o.output ilike '%not linux%'  then ' This is not linux OS.'
        when l.output = '' then h.output || ' recommendation is not applicable as the file is unavailable.'
        when o.output = '' then h.output || ' docker files and directories "docker.service" auditing is not configured.'
        else h.output || ' docker files and directories "docker.service" auditing is configured.'
      end as reason
    from
      hostname as h,
      command_output as o,
      file_location as l;
  EOQ
}

query "docker_files_and_directories_containerd_sock_auditing_configured" {
  sql = <<-EOQ
    with os_output as (
      select
        output
      from
        exec_command
      where
        command = 'uname -s'
    ), command_output as (
      select
        case
          when os_output.output ilike '%Darwin%' then 'not linux'
          else (select output from exec_command where command = 'sudo auditctl -l | grep containerd.sock')
        end as output
      from
        os_output
    ), file_location as (
        select
          case
            when os_output.output ilike '%Darwin%' then 'not linux'
            else (select output from exec_command where command = 'grep ''containerd.sock'' /etc/containerd/config.toml')
          end as output
        from
          os_output
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
        when o.output ilike '%not linux%' then 'skip'
        when l.output = '' then 'skip'
        when o.output = '' then 'alarm'
        else 'ok'
      end as status,
      case
        when o.output ilike '%not linux%'  then ' This is not linux OS.'
        when l.output = '' then h.output || ' recommendation is not applicable as the file is unavailable.'
        when o.output = '' then h.output || ' docker files and directories "containerd.sock" auditing is not configured.'
        else h.output || ' docker files and directories "containerd.sock" auditing is configured.'
      end as reason
    from
      hostname as h,
      command_output as o,
      file_location as l;
  EOQ
}

query "docker_files_and_directories_docker_socket_auditing_configured" {
  sql = <<-EOQ
    with os_output as (
      select
        output
      from
        exec_command
      where
        command = 'uname -s'
    ), command_output as (
      select
        case
          when os_output.output ilike '%Darwin%' then 'not linux'
          else (select output from exec_command where command = 'sudo auditctl -l | grep docker.socket')
        end as output
      from
        os_output
    ), file_location as (
        select
          case
            when os_output.output ilike '%Darwin%' then 'not linux'
            else (select output from exec_command where command = 'echo $(systemctl show -p FragmentPath docker.socket)')
          end as output
        from
          os_output
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
        when o.output ilike '%not linux%' then 'skip'
        when l.output = '' then 'skip'
        when o.output = '' then 'alarm'
        else 'ok'
      end as status,
      case
        when o.output ilike '%not linux%'  then ' This is not linux OS.'
        when l.output = '' then h.output || ' recommendation is not applicable as the file is unavailable.'
        when o.output = '' then h.output || ' docker files and directories "docker.socket" auditing is not configured.'
        else h.output || ' docker files and directories "docker.socket" auditing is configured.'
      end as reason
    from
      hostname as h,
      command_output as o,
      file_location as l;
  EOQ
}

query "docker_files_and_directories_etc_default_docker_auditing_configured" {
  sql = <<-EOQ
    with os_output as (
      select
        output
      from
        exec_command
      where
        command = 'uname -s'
    ), command_output as (
      select
        case
          when os_output.output ilike '%Darwin%' then 'not linux'
          else (select output from exec_command where command = 'sudo auditctl -l | grep /etc/default/docker')
        end as output
      from
        os_output
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
        when o.output ilike '%not linux%' then 'skip'
        when o.output = '' then 'alarm'
        else 'ok'
      end as status,
      case
        when o.output ilike '%not linux%'  then ' This is not linux OS.'
        when o.output = '' then h.output || ' docker files and directories "/etc/default/docker" auditing is not configured.'
        else h.output || ' docker files and directories "/etc/default/docker" auditing is configured.'
      end as reason
    from
      hostname as h,
      command_output as o;
  EOQ
}

query "docker_files_and_directories_etc_docker_daemon_auditing_configured" {
  sql = <<-EOQ
    with os_output as (
      select
        output
      from
        exec_command
      where
        command = 'uname -s'
    ), command_output as (
      select
        case
          when os_output.output ilike '%Darwin%' then 'not linux'
          else (select output from exec_command where command = 'sudo auditctl -l | grep /etc/docker/daemon.json')
        end as output
      from
        os_output
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
        when o.output ilike '%not linux%' then 'skip'
        when o.output = '' then 'alarm'
        else 'ok'
      end as status,
      case
        when o.output ilike '%not linux%'  then ' This is not linux OS.'
        when o.output = '' then h.output || ' docker files and directories "/etc/docker/daemon.json" auditing is not configured.'
        else h.output || ' docker files and directories "/etc/docker/daemon.json" auditing is configured.'
      end as reason
    from
      hostname as h,
      command_output as o;
  EOQ
}

query "docker_files_and_directories_etc_containerd_config_auditing_configured" {
  sql = <<-EOQ
    with os_output as (
      select
        output
      from
        exec_command
      where
        command = 'uname -s'
    ), command_output as (
      select
        case
          when os_output.output ilike '%Darwin%' then 'not linux'
          else (select output from exec_command where command = 'sudo auditctl -l | grep /etc/containerd/config.toml')
        end as output
      from
        os_output
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
        when o.output ilike '%not linux%' then 'skip'
        when o.output = '' then 'alarm'
        else 'ok'
      end as status,
      case
        when o.output ilike '%not linux%'  then ' This is not linux OS.'
        when o.output = '' then h.output || ' docker files and directories "/etc/containerd/config.toml" auditing is not configured.'
        else h.output || ' docker files and directories "/etc/containerd/config.toml" auditing is configured.'
      end as reason
    from
      hostname as h,
      command_output as o;
  EOQ
}

query "docker_files_and_directories_etc_sysconfig_docker_auditing_configured" {
  sql = <<-EOQ
    with os_output as (
      select
        output
      from
        exec_command
      where
        command = 'uname -s'
    ), command_output as (
      select
        case
          when os_output.output ilike '%Darwin%' then 'not linux'
          else (select output from exec_command where command = 'sudo auditctl -l | grep /etc/sysconfig/docker')
        end as output
      from
        os_output
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
        when o.output ilike '%not linux%' then 'skip'
        when o.output = '' then 'alarm'
        else 'ok'
      end as status,
      case
        when o.output ilike '%not linux%'  then ' This is not linux OS.'
        when o.output = '' then h.output || ' docker files and directories "/etc/sysconfig/docker" auditing is not configured.'
        else h.output || ' docker files and directories "/etc/sysconfig/docker" auditing is configured.'
      end as reason
    from
      hostname as h,
      command_output as o;
  EOQ
}

query "docker_files_and_directories_usr_bin_containerd_auditing_configured" {
  sql = <<-EOQ
    with os_output as (
      select
        output
      from
        exec_command
      where
        command = 'uname -s'
    ), command_output as (
      select
        case
          when os_output.output ilike '%Darwin%' then 'not linux'
          else (select output from exec_command where command = 'sudo auditctl -l | grep /usr/bin/containerd')
        end as output
      from
        os_output
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
        when o.output ilike '%not linux%' then 'skip'
        when o.output = '' then 'alarm'
        else 'ok'
      end as status,
      case
        when o.output ilike '%not linux%'  then ' This is not linux OS.'
        when o.output = '' then h.output || ' docker files and directories "/usr/bin/containerd" auditing is not configured.'
        else h.output || ' docker files and directories "/usr/bin/containerd" auditing is configured.'
      end as reason
    from
      hostname as h,
      command_output as o;
  EOQ
}

query "docker_files_and_directories_usr_bin_containerd_shim_auditing_configured" {
  sql = <<-EOQ
    with os_output as (
      select
        output
      from
        exec_command
      where
        command = 'uname -s'
    ), command_output as (
      select
        case
          when os_output.output ilike '%Darwin%' then 'not linux'
          else (select output from exec_command where command = 'sudo auditctl -l | grep /usr/bin/containerd-shim')
        end as output
      from
        os_output
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
        when o.output ilike '%not linux%' then 'skip'
        when o.output = '' then 'alarm'
        else 'ok'
      end as status,
      case
        when o.output ilike '%not linux%'  then ' This is not linux OS.'
        when o.output = '' then h.output || ' docker files and directories "/usr/bin/containerd-shim" auditing is not configured.'
        else h.output || ' docker files and directories "/usr/bin/containerd-shim" auditing is configured.'
      end as reason
    from
      hostname as h,
      command_output as o;
  EOQ
}

query "docker_files_and_directories_usr_bin_containerd_shim_runc_v1_auditing_configured" {
  sql = <<-EOQ
    with os_output as (
      select
        output
      from
        exec_command
      where
        command = 'uname -s'
    ), command_output as (
      select
        case
          when os_output.output ilike '%Darwin%' then 'not linux'
          else (select output from exec_command where command = 'sudo auditctl -l | grep /usr/bin/containerd-shim-runc-v1')
        end as output
      from
        os_output
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
        when o.output ilike '%not linux%' then 'skip'
        when o.output = '' then 'alarm'
        else 'ok'
      end as status,
      case
        when o.output ilike '%not linux%'  then ' This is not linux OS.'
        when o.output = '' then h.output || ' docker files and directories "/usr/bin/containerd-shim-runc-v1" auditing is not configured.'
        else h.output || ' docker files and directories "/usr/bin/containerd-shim-runc-v1" auditing is configured.'
      end as reason
    from
      hostname as h,
      command_output as o;
  EOQ
}

query "docker_files_and_directories_usr_bin_containerd_shim_runc_v2_auditing_configured" {
  sql = <<-EOQ
    with os_output as (
      select
        output
      from
        exec_command
      where
        command = 'uname -s'
    ), command_output as (
      select
        case
          when os_output.output ilike '%Darwin%' then 'not linux'
          else (select output from exec_command where command = 'sudo auditctl -l | grep /usr/bin/containerd-shim-runc-v2')
        end as output
      from
        os_output
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
        when o.output ilike '%not linux%' then 'skip'
        when o.output = '' then 'alarm'
        else 'ok'
      end as status,
      case
        when o.output ilike '%not linux%'  then ' This is not linux OS.'
        when o.output = '' then h.output || ' docker files and directories "/usr/bin/containerd-shim-runc-v2" auditing is not configured.'
        else h.output || ' docker files and directories "/usr/bin/containerd-shim-runc-v2" auditing is configured.'
      end as reason
    from
      hostname as h,
      command_output as o;
  EOQ
}

query "docker_files_and_directories_usr_bin_runc_auditing_configured" {
  sql = <<-EOQ
    with os_output as (
      select
        output
      from
        exec_command
      where
        command = 'uname -s'
    ), command_output as (
      select
        case
          when os_output.output ilike '%Darwin%' then 'not linux'
          else (select output from exec_command where command = 'sudo auditctl -l | grep /usr/bin/runc')
        end as output
      from
        os_output
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
        when o.output ilike '%not linux%' then 'skip'
        when o.output = '' then 'alarm'
        else 'ok'
      end as status,
      case
        when o.output ilike '%not linux%'  then ' This is not linux OS.'
        when o.output = '' then h.output || ' docker files and directories "/usr/bin/runc" auditing is not configured.'
        else h.output || ' docker files and directories "/usr/bin/runc" auditing is configured.'
      end as reason
    from
      hostname as h,
      command_output as o;
  EOQ
}

query "docker_container_trust_enabled" {
  sql = <<-EOQ
    with os_output as (
      select
        output
      from
        exec_command
      where
        command = 'uname -s'
    ), command_output as (
      select
        case
          when os_output.output ilike '%Darwin%' then 'not linux'
          else (select output from exec_command where command = 'echo $DOCKER_CONTENT_TRUST')
        end as output
      from
        os_output
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
        when o.output ilike '%not linux%' then 'skip'
        when o.output like '%1%' then 'ok'
        else 'alarm'
      end as status,
      case
        when o.output ilike '%not linux%'  then ' This is not linux OS.'
        when o.output like '%1%' then h.output || ' docker container trust enabled.'
        else h.output || ' docker container trust disabled.'
      end as reason
    from
      hostname as h,
      command_output as o;
  EOQ
}

query "docker_containerd_socket_file_restrictive_permission" {
  sql = <<-EOQ
    with os_output as (
      select
        output
      from
        exec_command
      where
        command = 'uname -s'
    ), command_output as (
      select
        case
          when os_output.output ilike '%Darwin%' then 'not linux'
          else (select output from exec_command where command = 'stat -c %a /run/containerd/containerd.sock')
        end as output
      from
        os_output
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
        when o.output ilike '%not linux%' then 'skip'
        when o.output like '%No such file or directory%' then 'skip'
        when o.output like '%660%' or o.output like '%600%' then 'ok'
        else 'alarm'
      end as status,
      case
        when o.output ilike '%not linux%'  then ' This is not linux OS.'
        when o.output like '%No such file or directory%' then h.output || ' recommendation is not applicable as the file is unavailable.'
        else h.output || ' containerd socket file permission set to ' || o.output || '.'
        end as reason
    from
      hostname as h,
      command_output as o;
  EOQ
}

query "docker_containerd_socket_file_ownership_root_root" {
  sql = <<-EOQ
    with os_output as (
      select
        output
      from
        exec_command
      where
        command = 'uname -s'
    ), command_output as (
      select
        case
          when os_output.output ilike '%Darwin%' then 'not linux'
          else (select output from exec_command where command = 'stat -c %U:%G /run/containerd/containerd.sock | grep -v root:root')
        end as output
      from
        os_output
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
        when o.output ilike '%not linux%' then 'skip'
        when o.output = '' then 'ok'
        else 'alarm'
      end as status,
      case
        when o.output ilike '%not linux%'  then ' This is not linux OS.'
        when o.output = '' then h.output || ' containerd socket file is owned by root and group owned by root.'
        else h.output || ' containerd socket file is not owned by root.'
      end as reason
    from
      hostname as h,
      command_output as o;
  EOQ
}

query "etc_sysconfig_docker_file_ownership_root_root" {
  sql = <<-EOQ
    with os_output as (
      select
        output
      from
        exec_command
      where
        command = 'uname -s'
    ), command_output as (
      select
        case
          when os_output.output ilike '%Darwin%' then 'not linux'
          else (select output from exec_command where command = 'stat -c %U:%G /etc/sysconfig/docker | grep -v root:root')
        end as output
      from
        os_output
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
         when o.output ilike '%not linux%' then 'skip'
        when o.output = '' then 'ok'
        else 'alarm'
      end as status,
      case
        when o.output ilike '%not linux%'  then ' This is not linux OS.'
        when o.output = '' then h.output  || ' /etc/sysconfig/docker file ownership is set to root:root.'
        else h.output  || ' /etc/sysconfig/docker file ownership is not set to root:root'
      end as reason
    from
      hostname as h,
      command_output as o;
  EOQ
}

query "etc_sysconfig_docker_file_restrictive_permission" {
  sql = <<-EOQ
    with os_output as (
      select
        output
      from
        exec_command
      where
        command = 'uname -s'
    ), command_output as (
      select
        case
          when os_output.output ilike '%Darwin%' then 'not linux'
          else (select output from exec_command where command = 'stat -c %a /etc/sysconfig/docker')
        end as output
      from
        os_output
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
        when o.output ilike '%not linux%' then 'skip'
        when o.output like '%No such file or directory%' then 'skip'
        when o.output like '%644%' then 'ok'
        else 'alarm'
      end as status,
      case
        when o.output ilike '%not linux%' then ' This is not linux OS.'
        when o.output like '%No such file or directory%' then h.output || ' recommendation is not applicable as the file is unavailable.'
        else h.output || ' containerd socket file permission set to ' || o.output || '.'
      end as reason
    from
      hostname as h,
      command_output as o;
  EOQ
}

query "docker_service_file_ownership_root_root" {
  sql = <<-EOQ
    with os_output as (
      select
        output
      from
        exec_command
      where
        command = 'uname -s'
    ), command_output as (
      select
        case
          when os_output.output ilike '%Darwin%' then 'not linux'
          else (select output from exec_command where command = 'stat -c %U:%G "$(systemctl show -p FragmentPath docker.service | awk -F''='' ''{print $2}'')" | grep -v root:root')
        end as output
      from
        os_output
    ), file_location as (
        select
          case
            when os_output.output ilike '%Darwin%' then 'not linux'
            else (select output from exec_command where command = 'echo $(systemctl show -p FragmentPath docker.service)')
          end as output
        from
          os_output
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
        when o.output ilike '%not linux%' then 'skip'
        when l.output = '' then 'skip'
        when o.output = '' then 'ok'
        else 'alarm'
      end as status,
      case
        when o.output ilike '%not linux%'  then ' This is not linux OS.'
        when l.output = '' then h.output || ' recommendation is not applicable as the file is unavailable.'
        when o.output = '' then h.output || ' docker.service file ownership is set to root:root.'
        else h.output || ' docker.service file ownership is not set to root:root.'
      end as reason
    from
      hostname as h,
      command_output as o,
      file_location as l;
  EOQ
}

query "docker_service_file_restrictive_permission" {
  sql = <<-EOQ
    with os_output as (
      select
        output
      from
        exec_command
      where
        command = 'uname -s'
    ), command_output as (
      select
        case
          when os_output.output ilike '%Darwin%' then 'not linux'
          else (select output from exec_command where command = 'stat -c %a "$(systemctl show -p FragmentPath docker.service | awk -F''='' ''{print $2}'')"')
        end as output
      from
        os_output
    ), file_location as (
        select
          case
            when os_output.output ilike '%Darwin%' then 'not linux'
            else (select output from exec_command where command = 'echo $(systemctl show -p FragmentPath docker.service)')
          end as output
        from
          os_output
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
        when o.output ilike '%not linux%' then 'skip'
        when l.output = '' then 'skip'
        when o.output like '%644%' then 'ok'
        else 'alarm'
      end as status,
      case
        when o.output ilike '%not linux%'  then ' This is not linux OS.'
        when l.output = '' then h.output || ' recommendation is not applicable as the file is unavailable.'
        else  h.output || ' docker.service file permission set to ' || o.output || '.'
      end as reason
    from
      hostname as h,
      command_output as o,
      file_location as l;
  EOQ
}

query "docker_socket_file_restrictive_permission" {
  sql = <<-EOQ
    with os_output as (
      select
        output
      from
        exec_command
      where
        command = 'uname -s'
    ), command_output as (
      select
        case
          when os_output.output ilike '%Darwin%' then 'not linux'
          else (select output from exec_command where command = 'stat -c %a "$(systemctl show -p FragmentPath docker.socket | awk -F''='' ''{print $2}'')"')
        end as output
      from
        os_output
    ), file_location as (
        select
          case
            when os_output.output ilike '%Darwin%' then 'not linux'
            else (select output from exec_command where command = 'echo $(systemctl show -p FragmentPath docker.socket)')
          end as output
        from
          os_output
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
        when o.output ilike '%not linux%' then 'skip'
        when l.output = '' then 'skip'
        when o.output like '%644%' then 'ok'
        else 'alarm'
      end as status,
      case
        when o.output ilike '%not linux%'  then ' This is not linux OS.'
        when l.output = '' then h.output || ' recommendation is not applicable as the file is unavailable.'
        else  h.output || ' docker.socket file permission set to ' || o.output || '.'
      end as reason
    from
      hostname as h,
      command_output as o,
      file_location as l;
  EOQ
}

query "etc_docker_directory_restrictive_permission" {
  sql = <<-EOQ
    with os_output as (
      select
        output
      from
        exec_command
      where
        command = 'uname -s'
    ), command_output as (
      select
        case
          when os_output.output ilike '%Darwin%' then 'not linux'
          else (select output from exec_command where command = 'stat -c %a /etc/docker')
        end as output
      from
        os_output
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
        when o.output ilike '%not linux%' then 'skip'
        when o.output like '%No such file or directory%' then 'skip'
        when o.output like '%755%' then 'ok'
        else 'alarm'
      end as status,
      case
        when o.output ilike '%not linux%'  then ' This is not linux OS.'
        when o.output like '%No such file or directory%' then h.output || ' recommendation is not applicable as the file is unavailable.'
        else h.output || ' /etc/docker directory permission set to ' || o.output || '.'
        end as reason
    from
      hostname as h,
      command_output as o;
  EOQ
}

query "docker_socket_file_ownership_root_docker" {
  sql = <<-EOQ
    with os_output as (
      select
        output
      from
        exec_command
      where
        command = 'uname -s'
    ), command_output as (
      select
        case
          when os_output.output ilike '%Darwin%' then 'not linux'
          else (select output from exec_command where command = 'stat -c %U:%G /var/run/docker.sock | grep -v root:docker')
        end as output
      from
        os_output
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
        when o.output ilike '%not linux%' then 'skip'
        when o.output = '' then 'ok'
        else 'alarm'
      end as status,
      case
        when o.output ilike '%not linux%'  then ' This is not linux OS.'
        when o.output = '' then h.output || ' docker socket file ownership is set to root:docker.'
        else h.output || ' docker socket file ownership is not set to root:docker.'
      end as reason
    from
      hostname as h,
      command_output as o;
  EOQ
}

query "docker_sock_file_restrictive_permission" {
  sql = <<-EOQ
    with os_output as (
      select
        output
      from
        exec_command
      where
        command = 'uname -s'
    ), command_output as (
      select
        case
          when os_output.output ilike '%Darwin%' then 'not linux'
          else (select output from exec_command where command = 'stat -c %a /var/run/docker.sock')
        end as output
      from
        os_output
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
        when o.output ilike '%not linux%' then 'skip'
        when o.output like '%No such file or directory%' then 'skip'
        when o.output like '%660%' then 'ok'
        else 'alarm'
      end as status,
      case
        when o.output ilike '%not linux%'  then ' This is not linux OS.'
        when o.output like h.output || '%No such file or directory%' then ' recommendation is not applicable as the file is unavailable.'
        else h.output || ' docker.socket file permission set to ' || o.output || '.'
      end as reason
    from
      hostname as h,
      command_output as o;
  EOQ
}

query "daemon_json_file_ownership_root_root" {
  sql = <<-EOQ
    with os_output as (
      select
        output
      from
        exec_command
      where
        command = 'uname -s'
    ), command_output as (
      select
        case
          when os_output.output ilike '%Darwin%' then 'not linux'
          else (select output from exec_command where command = 'stat -c %U:%G /etc/docker/daemon.json | grep -v root:root')
        end as output
      from
        os_output
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
        when o.output ilike '%not linux%' then 'skip'
        when o.output like '%No such file or directory%' then 'skip'
        when o.output = '' then 'ok'
        else 'alarm'
      end as status,
      case
        when o.output ilike '%not linux%'  then ' This is not linux OS.'
        when o.output like '%No such file or directory%' then h.output || ' recommendation is not applicable as the file is unavailable.'
        when o.output = '' then h.output || ' daemon.json file ownership is set to root:root.'
        else h.output || ' docker socket file ownership is not set to root:root.'
      end as reason
    from
      hostname as h,
      command_output as o;
  EOQ
}

query "daemon_json_file_restrictive_permission" {
  sql = <<-EOQ
    with os_output as (
      select
        output
      from
        exec_command
      where
        command = 'uname -s'
    ), command_output as (
      select
        case
          when os_output.output ilike '%Darwin%' then 'not linux'
          else (select output from exec_command where command = 'stat -c %a /etc/docker/daemon.json')
        end as output
      from
        os_output
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
        when o.output ilike '%not linux%' then 'skip'
        when o.output like '%No such file or directory%' then 'skip'
        when o.output like '%644%' then 'ok'
        else 'alarm'
      end as status,
      case
        when o.output ilike '%not linux%'  then ' This is not linux OS.'
        when o.output like '%No such file or directory%' then h.output || ' recommendation is not applicable as the file is unavailable.'
        else h.output || ' daemon.json file permission set to ' || o.output || '.'
      end as reason
    from
      hostname as h,
      command_output as o;
  EOQ
}

query "etc_default_docker_file_ownership_root_root" {
  sql = <<-EOQ
    with os_output as (
      select
        output
      from
        exec_command
      where
        command = 'uname -s'
    ), command_output as (
      select
        case
          when os_output.output ilike '%Darwin%' then 'not linux'
          else (select output from exec_command where command = 'stat -c %U:%G /etc/default/docker | grep -v root:root')
        end as output
      from
        os_output
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
        when o.output ilike '%not linux%' then 'skip'
        when o.output like '%No such file or directory%' then 'skip'
        when o.output = '' then 'ok'
        else 'alarm'
      end as status,
      case
        when o.output ilike '%not linux%'  then ' This is not linux OS.'
        when o.output like '%No such file or directory%' then h.output || ' recommendation is not applicable as the file is unavailable.'
        when o.output = '' then h.output || ' /etc/default/docker file ownership is set to root:root.'
        else h.output || ' /etc/default/docker file ownership is not set to root:root.'
      end as reason
    from
      hostname as h,
      command_output as o;
  EOQ
}

query "etc_default_docker_file_restrictive_permission" {
  sql = <<-EOQ
    with os_output as (
      select
        output
      from
        exec_command
      where
        command = 'uname -s'
    ), command_output as (
      select
        case
          when os_output.output ilike '%Darwin%' then 'not linux'
          else (select output from exec_command where command = 'stat -c %a /etc/default/docker')
        end as output
      from
        os_output
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
        when o.output ilike '%not linux%' then 'skip'
        when o.output like '%No such file or directory%' then 'skip'
        when o.output like '%644%' then 'ok'
        else 'alarm'
      end as status,
      case
        when o.output ilike '%not linux%'  then ' This is not linux OS.'
        when o.output like '%No such file or directory%' then h.output || ' recommendation is not applicable as the file is unavailable.'
        else h.output || ' /etc/default/docker file permission set to ' || o.output || '.'
      end as reason
    from
      hostname as h,
      command_output as o;
  EOQ
}

query "docker_exec_command_no_privilege_option" {
  sql = <<-EOQ
    with os_output as (
      select
        output
      from
        exec_command
      where
        command = 'uname -s'
    ), command_output as (
      select
        case
          when os_output.output ilike '%Darwin%' then 'not linux'
          else (select output from exec_command where command = 'sudo ausearch -k docker | grep exec | grep privileged')
        end as output
      from
        os_output
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
        when o.output ilike '%not linux%' then 'skip'
        when o.output like '' then 'ok'
        else 'alarm'
      end as status,
      case
        when o.output ilike '%not linux%'  then ' This is not linux OS.'
        when o.output like '' then h.output || ' docker exec commands are not used with the privileged option.'
        else h.output || ' docker exec commands are used with the privileged option.'
      end as reason
    from
      hostname as h,
      command_output as o;
  EOQ
}

query "docker_exec_command_no_user_root_option" {
  sql = <<-EOQ
    with os_output as (
      select
        output
      from
        exec_command
      where
        command = 'uname -s'
    ), command_output as (
      select
        case
          when os_output.output ilike '%Darwin%' then 'not linux'
          else (select output from exec_command where command = 'sudo ausearch -k docker | grep exec | grep user')
        end as output
      from
        os_output
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
        when o.output ilike '%not linux%' then 'skip'
        when o.output like '' then 'ok'
        else 'alarm'
      end as status,
      case
        when o.output ilike '%not linux%'  then ' This is not linux OS.'
        when o.output like '' then h.output || ' docker exec commands are not used with the user=root option'
        else h.output || ' docker exec commands are used with the user=root option.'
      end as reason
    from
      hostname as h,
      command_output as o;
  EOQ
}

query "registry_certificate_ownership_root_root" {
  sql = <<-EOQ
    with os_output as (
      select
        output
      from
        exec_command
      where
        command = 'uname -s'
    ), command_output as (
      select
        case
          when os_output.output ilike '%Darwin%' then 'not linux'
          else (select output from exec_command where command = 'stat -c %U:%G /etc/docker/certs.d/* | grep -v root:root')
        end as output
      from
        os_output
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
        when o.output ilike '%not linux%' then 'skip'
        when o.output = '' then 'ok'
        else 'alarm'
      end as status,
      case
        when o.output ilike '%not linux%'  then ' This is not linux OS.'
        when o.output = '' then h.output || ' registry certificate file ownership is set to root:root.'
        else h.output || ' registry certificate file ownership is not set to root:root.'
      end as reason
    from
      hostname as h,
      command_output as o;
  EOQ
}

query "registry_certificate_file_permissions_444" {
  sql = <<-EOQ
    with os_output as (
      select
        output
      from
        exec_command
      where
        command = 'uname -s'
    ), command_output as (
      select
        case
          when os_output.output ilike '%Darwin%' then 'not linux'
          else (select output from exec_command where command = 'find /etc/docker/certs.d/ -type f -exec stat -c "%a %n" {} \;')
        end as output
      from
        os_output
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
        when o.output ilike '%not linux%' then 'skip'
        when o.output like '%No such file or directory%' then 'skip'
        when o.output like '%444%' then 'ok'
        else 'alarm'
      end as status,
      case
        when o.output ilike '%not linux%'  then ' This is not linux OS.'
        when o.output like '%No such file or directory%' then h.output || ' recommendation is not applicable as the file is unavailable.'
        else h.output || ' registry certificate file permissions set to ' || o.output || '.'
      end as reason
    from
      hostname as h,
      command_output as o;
  EOQ
}

query "docker_iptables_not_set" {
  sql = <<-EOQ
    with os_output as (
      select
        output
      from
        exec_command
      where
        command = 'uname -s'
    ), command_output as (
      select
        case
          when os_output.output ilike '%Darwin%' then 'not linux'
          else (select output from exec_command where command = 'ps -ef | grep dockerd')
        end as output
      from
        os_output
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
        when o.output ilike '%not linux%' then 'skip'
        when o.output like '%--iptables=false%' then 'ok'
        when o.output not like '%--iptables%' then 'ok'
        else 'alarm'
      end as status,
      case
        when o.output ilike '%not linux%'  then ' This is not linux OS.'
        when o.output like '%--iptables=false%' then h.output || ' iptables is set to false.'
        when o.output not like '%--iptables%' then h.output || ' iptables not set.'
        else h.output || ' iptables are set to true.'
      end as reason
    from
      hostname as h,
      command_output as o;
  EOQ
}

query "userland_proxy_disabled" {
  sql = <<-EOQ
    with os_output as (
      select
        output
      from
        exec_command
      where
        command = 'uname -s'
    ), command_output as (
      select
        case
          when os_output.output ilike '%Darwin%' then 'not linux'
          else (select output from exec_command where command = 'ps -ef | grep dockerd')
        end as output
      from
        os_output
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
        when o.output ilike '%not linux%' then 'skip'
        when o.output like '%--userland-proxy=false%' then 'ok'
        else 'alarm'
      end as status,
      case
        when o.output ilike '%not linux%'  then ' This is not linux OS.'
        when o.output like '%--userland-proxy=false%' then h.output || ' userland proxy is Disabled.'
        else h.output || ' userland proxy is enabled.'
      end as reason
    from
      hostname as h,
      command_output as o;
  EOQ
}

query "containers_no_new_privilege_disabled" {
  sql = <<-EOQ
    with os_output as (
      select
        output
      from
        exec_command
      where
        command = 'uname -s'
    ), command_output as (
      select
        case
          when os_output.output ilike '%Darwin%' then 'not linux'
          else (select output from exec_command where command = 'ps -ef | grep dockerd')
        end as output
      from
        os_output
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
        when o.output ilike '%not linux%' then 'skip'
        when o.output like '%--no-new-privileges=false%' then 'alarm'
        when o.output not like '%--no-new-privileges%' then 'alarm'
        else 'ok'
      end as status,
      case
        when o.output ilike '%not linux%'  then ' This is not linux OS.'
        when o.output like '%--no-new-privileges=false%' then h.output  || ' no new privileges is disabled.'
        when o.output not like '%--no-new-privileges%' then h.output  || ' no new privileges not set.'
        else h.output || ' no new privilege is enabled.'
      end as reason
    from
      hostname as h,
      command_output as o;
  EOQ
}
