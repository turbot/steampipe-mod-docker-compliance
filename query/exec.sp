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

query "docker_files_and_directories_run_containerd_auditing_configured" {
  sql = <<-EOQ
    with command_output as (
      select
        output
      from
        exec_command
      where
        command = 'sudo auditctl -l | grep /run/containerd'
    )
    select
      id as resource,
      case
        when output = '' then 'alarm'
        else 'ok'
      end as status,
      case
        when output = '' then name || ' docker files and directories "/run/containerd" auditing is not configured.'
        else name || ' docker files and directories "/run/containerd" auditing is configured.'
      end as reason
    from
      docker_info,
      command_output;
  EOQ
}

query "docker_files_and_directories_var_lib_docker_auditing_configured" {
  sql = <<-EOQ
    with command_output as (
      select
        output
      from
        exec_command
      where
        command = 'sudo auditctl -l | grep /var/lib/docker'
    )
    select
      id as resource,
      case
        when output = '' then 'alarm'
        else 'ok'
      end as status,
      case
        when output = '' then name || ' docker files and directories "/var/lib/docker" auditing is not configured.'
        else name || ' docker files and directories "/var/lib/docker" auditing is configured.'
      end as reason
    from
      docker_info,
      command_output;
  EOQ
}

query "docker_files_and_directories_etc_docker_auditing_configured" {
  sql = <<-EOQ
    with command_output as (
      select
        output
      from
        exec_command
      where
        command = 'sudo auditctl -l | grep /etc/docker'
    )
    select
      id as resource,
      case
        when output = '' then 'alarm'
        else 'ok'
      end as status,
      case
        when output = '' then name || ' docker files and directories "/etc/docker" auditing is not configured.'
        else name || ' docker files and directories "/etc/docker" auditing is configured.'
      end as reason
    from
      docker_info,
      command_output;
  EOQ
}

query "docker_files_and_directories_docker_service_auditing_configured" {
  sql = <<-EOQ
    with command_output as (
      select
        output
      from
        exec_command
      where
        command = 'sudo auditctl -l | grep docker.service'
    ),file_location as (
        select
          output
        from
          exec_command
        where
          command = 'systemctl show -p FragmentPath docker.service'
    )
    select
      id as resource,
      case
        when l.output = '' then 'skip'
        when o.output = '' then 'alarm'
        else 'ok'
      end as status,
      case
        when l.output = '' then name || ' recommendation is not applicable as the file is unavailable.'
        when o.output = '' then name || ' docker files and directories "docker.service" auditing is not configured.'
        else name || ' docker files and directories "docker.service" auditing is configured.'
      end as reason
    from
      docker_info,
      command_output as o,
      file_location as l;
  EOQ
}

query "docker_files_and_directories_containerd_sock_auditing_configured" {
  sql = <<-EOQ
    with command_output as (
      select
        output
      from
        exec_command
      where
        command = 'sudo auditctl -l | grep containerd.sock'
    ),file_location as (
        select
          output
        from
          exec_command
        where
          command = 'grep ''containerd.sock'' /etc/containerd/config.toml'
    )
    select
      id as resource,
      case
        when l.output = '' then 'skip'
        when o.output = '' then 'alarm'
        else 'ok'
      end as status,
      case
        when l.output = '' then name || ' recommendation is not applicable as the file is unavailable.'
        when o.output = '' then name || ' docker files and directories "containerd.sock" auditing is not configured.'
        else name || ' docker files and directories "containerd.sock" auditing is configured.'
      end as reason
    from
      docker_info,
      command_output as o,
      file_location as l;
  EOQ
}

query "docker_files_and_directories_docker_socket_auditing_configured" {
  sql = <<-EOQ
    with command_output as (
      select
        output
      from
        exec_command
      where
        command = 'sudo auditctl -l | grep docker.socket'
    ),file_location as (
        select
          output
        from
          exec_command
        where
          command = 'systemctl show -p FragmentPath docker.socket'
    )
    select
      id as resource,
      case
        when l.output = '' then 'skip'
        when o.output = '' then 'alarm'
        else 'ok'
      end as status,
      case
        when l.output = '' then name || ' recommendation is not applicable as the file is unavailable.'
        when o.output = '' then name || ' docker files and directories "docker.socket" auditing is not configured.'
        else name || ' docker files and directories "docker.socket" auditing is configured.'
      end as reason
    from
      docker_info,
      command_output as o,
      file_location as l;
  EOQ
}

query "docker_files_and_directories_etc_default_docker_auditing_configured" {
  sql = <<-EOQ
    with command_output as (
      select
        output
      from
        exec_command
      where
        command = 'sudo auditctl -l | grep /etc/default/docker'
    )
    select
      id as resource,
      case
        when o.output = '' then 'alarm'
        else 'ok'
      end as status,
      case
        when o.output = '' then name || ' docker files and directories "/etc/default/docker" auditing is not configured.'
        else name || ' docker files and directories "/etc/default/docker" auditing is configured.'
      end as reason
    from
      docker_info,
      command_output as o;
  EOQ
}

query "docker_files_and_directories_etc_docker_daemon_auditing_configured" {
  sql = <<-EOQ
    with command_output as (
      select
        output
      from
        exec_command
      where
        command = 'sudo auditctl -l | grep /etc/docker/daemon.json'
    )
    select
      id as resource,
      case
        when o.output = '' then 'alarm'
        else 'ok'
      end as status,
      case
        when o.output = '' then name || ' docker files and directories "/etc/docker/daemon.json" auditing is not configured.'
        else name || ' docker files and directories "/etc/docker/daemon.json" auditing is configured.'
      end as reason
    from
      docker_info,
      command_output as o;
  EOQ
}

query "docker_files_and_directories_etc_containerd_config_auditing_configured" {
  sql = <<-EOQ
    with command_output as (
      select
        output
      from
        exec_command
      where
        command = 'sudo auditctl -l | grep /etc/containerd/config.toml'
    )
    select
      id as resource,
      case
        when o.output = '' then 'alarm'
        else 'ok'
      end as status,
      case
        when o.output = '' then name || ' docker files and directories "/etc/containerd/config.toml" auditing is not configured.'
        else name || ' docker files and directories "/etc/containerd/config.toml" auditing is configured.'
      end as reason
    from
      docker_info,
      command_output as o;
  EOQ
}

query "docker_files_and_directories_etc_sysconfig_docker_auditing_configured" {
  sql = <<-EOQ
    with command_output as (
      select
        output
      from
        exec_command
      where
        command = 'sudo auditctl -l | grep /etc/sysconfig/docker'
    )
    select
      id as resource,
      case
        when o.output = '' then 'alarm'
        else 'ok'
      end as status,
      case
        when o.output = '' then name || ' docker files and directories "/etc/sysconfig/docker" auditing is not configured.'
        else name || ' docker files and directories "/etc/sysconfig/docker" auditing is configured.'
      end as reason
    from
      docker_info,
      command_output as o;
  EOQ
}

query "docker_files_and_directories_usr_bin_containerd_auditing_configured" {
  sql = <<-EOQ
    with command_output as (
      select
        output
      from
        exec_command
      where
        command = 'sudo auditctl -l | grep /usr/bin/containerd'
    )
    select
      id as resource,
      case
        when o.output = '' then 'alarm'
        else 'ok'
      end as status,
      case
        when o.output = '' then name || ' docker files and directories "/usr/bin/containerd" auditing is not configured.'
        else name || ' docker files and directories "/usr/bin/containerd" auditing is configured.'
      end as reason
    from
      docker_info,
      command_output as o;
  EOQ
}

query "docker_files_and_directories_usr_bin_containerd_shim_auditing_configured" {
  sql = <<-EOQ
    with command_output as (
      select
        output
      from
        exec_command
      where
        command = 'sudo auditctl -l | grep /usr/bin/containerd-shim'
    )
    select
      id as resource,
      case
        when o.output = '' then 'alarm'
        else 'ok'
      end as status,
      case
        when o.output = '' then name || ' docker files and directories "/usr/bin/containerd-shim" auditing is not configured.'
        else name || ' docker files and directories "/usr/bin/containerd-shim" auditing is configured.'
      end as reason
    from
      docker_info,
      command_output as o;
  EOQ
}

query "docker_files_and_directories_usr_bin_containerd_shim_runc_v1_auditing_configured" {
  sql = <<-EOQ
    with command_output as (
      select
        output
      from
        exec_command
      where
        command = 'sudo auditctl -l | grep /usr/bin/containerd-shim-runc-v1'
    )
    select
      id as resource,
      case
        when o.output = '' then 'alarm'
        else 'ok'
      end as status,
      case
        when o.output = '' then name || ' docker files and directories "/usr/bin/containerd-shim-runc-v1" auditing is not configured.'
        else name || ' docker files and directories "/usr/bin/containerd-shim-runc-v1" auditing is configured.'
      end as reason
    from
      docker_info,
      command_output as o;
  EOQ
}

query "docker_files_and_directories_usr_bin_containerd_shim_runc_v2_auditing_configured" {
  sql = <<-EOQ
    with command_output as (
      select
        output
      from
        exec_command
      where
        command = 'sudo auditctl -l | grep /usr/bin/containerd-shim-runc-v2'
    )
    select
      id as resource,
      case
        when o.output = '' then 'alarm'
        else 'ok'
      end as status,
      case
        when o.output = '' then name || ' docker files and directories "/usr/bin/containerd-shim-runc-v2" auditing is not configured.'
        else name || ' docker files and directories "/usr/bin/containerd-shim-runc-v2" auditing is configured.'
      end as reason
    from
      docker_info,
      command_output as o;
  EOQ
}

query "docker_files_and_directories_usr_bin_runc_auditing_configured" {
  sql = <<-EOQ
    with command_output as (
      select
        output
      from
        exec_command
      where
        command = 'sudo auditctl -l | grep /usr/bin/runc'
    )
    select
      id as resource,
      case
        when o.output = '' then 'alarm'
        else 'ok'
      end as status,
      case
        when o.output = '' then name || ' docker files and directories "/usr/bin/runc" auditing is not configured.'
        else name || ' docker files and directories "/usr/bin/runc" auditing is configured.'
      end as reason
    from
      docker_info,
      command_output as o;
  EOQ
}

query "docker_container_trust_enabled" {
  sql = <<-EOQ
    with command_output as (
      select
        output
      from
        exec_command
      where
        command = 'echo $DOCKER_CONTENT_TRUST'
    )
    select
      id as resource,
      o.output,
      case
        when o.output like '%1%' then 'ok'
        else 'alarm'
      end as status,
      case
        when o.output like '%1%' then name || ' docker container trust enabled.'
        else name || ' docker container trust disabled.'
      end as reason
    from
      docker_info,
      command_output as o;
  EOQ
}

query "docker_containerd_socket_file_restrictive_permission" {
  sql = <<-EOQ
    with command_output as (
      select
        output
      from
        exec_command
      where
        command = 'stat -c %a /run/containerd/containerd.sock'
    )
    select
      id as resource,
      case
        when o.output like '%660%' or o.output like '%600%' then 'ok'
        else 'alarm'
      end as status,
      name || ' containerd socket file permission set to ' || o.output || '.' as reason
    from
      docker_info,
      command_output as o;
  EOQ
}

query "docker_containerd_socket_file_ownership_root_root" {
  sql = <<-EOQ
    with command_output as (
      select
        output
      from
        exec_command
      where
        command = 'stat -c %U:%G /run/containerd/containerd.sock | grep -v root:root'
    )
    select
      id as resource,
      case
        when o.output = '' then 'ok'
        else 'alarm'
      end as status,
      case
        when o.output = '' then name || ' containerd socket file is owned by root and group owned by root.'
        else name || ' containerd socket file is not owned by root.'
      end as reason
    from
      docker_info,
      command_output as o;
  EOQ
}

query "etc_sysconfig_docker_file_ownership_root_root" {
  sql = <<-EOQ
    with command_output as (
      select
        output
      from
        exec_command
      where
        command = 'stat -c %U:%G /etc/sysconfig/docker | grep -v root:root'
    )
    select
      id as resource,
      case
        when o.output = '' then 'ok'
        else 'alarm'
      end as status,
      case
        when o.output = '' then name || ' /etc/sysconfig/docker file ownership is set to root:root.'
        else name || ' /etc/sysconfig/docker file ownership is not set to root:root'
      end as reason
    from
      docker_info,
      command_output as o;
  EOQ
}

query "etc_sysconfig_docker_file_restrictive_permission" {
  sql = <<-EOQ
    with command_output as (
      select
        output
      from
        exec_command
      where
        command = 'stat -c %a /etc/sysconfig/docker'
    )
    select
      id as resource,
      case
        when o.output like '%644%' then 'ok'
        else 'alarm'
      end as status,
      name || ' containerd socket file permission set to ' || o.output || '.' as reason
    from
      docker_info,
      command_output as o;
  EOQ
}

query "docker_service_file_ownership_root_root" {
  sql = <<-EOQ
    with command_output as (
      select
        output
      from
        exec_command
      where
        command = 'stat -c %U:%G "$(systemctl show -p FragmentPath docker.service | awk -F''='' ''{print $2}'')" | grep -v root:root'
    ),file_location as (
        select
          output
        from
          exec_command
        where
          command = 'systemctl show -p FragmentPath docker.service'
    )
    select
      id as resource,
      case
        when l.output = '' then 'skip'
        when o.output = '' then 'ok'
        else 'alarm'
      end as status,
      case
        when l.output = '' then name || ' recommendation is not applicable as the file is unavailable.'
        when o.output = '' then name || ' docker.service file ownership is set to root:root.'
        else name || ' docker.service file ownership is not set to root:root.'
      end as reason
    from
      docker_info,
      command_output as o,
      file_location as l;
  EOQ
}

query "docker_service_file_restrictive_permission" {
  sql = <<-EOQ
    with command_output as (
      select
        output
      from
        exec_command
      where
        command = 'stat -c %a "$(systemctl show -p FragmentPath docker.service | awk -F''='' ''{print $2}'')"'
    ),file_location as (
        select
          output
        from
          exec_command
        where
          command = 'systemctl show -p FragmentPath docker.service'
    )
    select
      id as resource,
      case
        when l.output = '' then 'skip'
        when o.output like '%644%' then 'ok'
        else 'alarm'
      end as status,
      case
        when l.output = '' then name || ' recommendation is not applicable as the file is unavailable.'
        else  name || ' docker.service file permission set to ' || o.output || '.'
      end as reason
    from
      docker_info,
      command_output as o,
      file_location as l;
  EOQ
}

query "docker_socket_file_restrictive_permission" {
  sql = <<-EOQ
    with command_output as (
      select
        output
      from
        exec_command
      where
        command = 'stat -c %a "$(systemctl show -p FragmentPath docker.socket | awk -F''='' ''{print $2}'')"'
    ),file_location as (
        select
          output
        from
          exec_command
        where
          command = 'systemctl show -p FragmentPath docker.socket'
    )
    select
      id as resource,
      case
        when l.output = '' then 'skip'
        when o.output like '%644%' then 'ok'
        else 'alarm'
      end as status,
      case
        when l.output = '' then name || ' recommendation is not applicable as the file is unavailable.'
        else  name || ' docker.socket file permission set to ' || o.output || '.'
      end as reason
    from
      docker_info,
      command_output as o,
      file_location as l;
  EOQ
}

query "etc_docker_directory_restrictive_permission" {
  sql = <<-EOQ
    with command_output as (
      select
        output
      from
        exec_command
      where
        command = 'stat -c %a /etc/docker'
    )
    select
      id as resource,
      case
        when o.output like '%755%' then 'ok'
        else 'alarm'
      end as status,
        name || ' /etc/docker directory permission set to ' || o.output || '.'  as reason
    from
      docker_info,
      command_output as o;
  EOQ
}

query "docker_socket_file_ownership_root_docker" {
  sql = <<-EOQ
    with command_output as (
      select
        output
      from
        exec_command
      where
        command = 'stat -c %U:%G /var/run/docker.sock | grep -v root:docker'
    )
    select
      id as resource,
      case
        when o.output = '' then 'ok'
        else 'alarm'
      end as status,
      case
        when o.output = '' then name || ' docker socket file ownership is set to root:docker.'
        else name || ' docker socket file ownership is not set to root:docker.'
      end as reason
    from
      docker_info,
      command_output as o;
  EOQ
}

query "docker_sock_file_restrictive_permission" {
  sql = <<-EOQ
    with command_output as (
      select
        output
      from
        exec_command
      where
        command = 'stat -c %a /var/run/docker.sock'
    )
    select
      id as resource,
      case
        when o.output like '%660%' then 'ok'
        else 'alarm'
      end as status,
      name || ' docker.socket file permission set to ' || o.output || '.' as reason
    from
      docker_info,
      command_output as o;
  EOQ
}

query "daemon_json_file_ownership_root_root" {
  sql = <<-EOQ
    with command_output as (
      select
        output
      from
        exec_command
      where
        command = 'stat -c %U:%G /etc/docker/daemon.json | grep -v root:root '
    )
    select
      id as resource,
      case
        when o.output like '%No such file or directory%' then 'skip'
        when o.output = '' then 'ok'
        else 'alarm'
      end as status,
      case
        when o.output like '%No such file or directory%' then name || ' recommendation is not applicable as the file is unavailable.'
        when o.output = '' then name || ' daemon.json file ownership is set to root:root.'
        else name || ' docker socket file ownership is not set to root:root.'
      end as reason
    from
      docker_info,
      command_output as o;
  EOQ
}

query "daemon_json_file_restrictive_permission" {
  sql = <<-EOQ
    with command_output as (
      select
        output
      from
        exec_command
      where
        command = 'stat -c %a /etc/docker/daemon.json'
    )
    select
      id as resource,
      case
        when o.output like '%No such file or directory%' then 'skip'
        when o.output like '%644%' then 'ok'
        else 'alarm'
      end as status,
      case
        when o.output like '%No such file or directory%' then name || ' recommendation is not applicable as the file is unavailable.'
        else name || ' daemon.json file permission set to ' || o.output || '.'
      end as reason
    from
      docker_info,
      command_output as o;
  EOQ
}

query "etc_default_docker_file_ownership_root_root" {
  sql = <<-EOQ
    with command_output as (
      select
        output
      from
        exec_command
      where
        command = 'stat -c %U:%G /etc/default/docker | grep -v root:root'
    )
    select
      id as resource,
      case
        when o.output like '%No such file or directory%' then 'skip'
        when o.output = '' then 'ok'
        else 'alarm'
      end as status,
      case
        when o.output like '%No such file or directory%' then name || ' recommendation is not applicable as the file is unavailable.'
        when o.output = '' then name || ' /etc/default/docker file ownership is set to root:root.'
        else name || ' /etc/default/docker file ownership is not set to root:root.'
      end as reason
    from
      docker_info,
      command_output as o;
  EOQ
}

query "etc_default_docker_file_restrictive_permission" {
  sql = <<-EOQ
    with command_output as (
      select
        output
      from
        exec_command
      where
        command = 'stat -c %a /etc/default/docker'
    )
    select
      id as resource,
      case
        when o.output like '%No such file or directory%' then 'skip'
        when o.output like '%644%' then 'ok'
        else 'alarm'
      end as status,
      case
        when o.output like '%No such file or directory%' then name || ' recommendation is not applicable as the file is unavailable.'
        else name || ' /etc/default/docker file permission set to ' || o.output || '.'
      end as reason
    from
      docker_info,
      command_output as o;
  EOQ
}
