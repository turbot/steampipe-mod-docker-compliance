locals {
  os_hostname_sql = <<-EOQ
    with os_output as (
      select
        btrim(stdout_output, E' \n\r\t') as os,
        _ctx ->> 'connection_name' as os_conn
      from
        exec_command
      where
        command = 'uname -s'
    ), hostname as (
      select
        btrim(stdout_output, E' \n\r\t') as host,
         _ctx ->> 'connection_name' as host_conn
      from
        exec_command
      where
        command = 'hostname'
    ),
  EOQ
}

locals {
  hostname_sql = <<-EOQ
    with hostname as (
      select
        btrim(stdout_output, E' \n\r\t') as host,
         _ctx ->> 'connection_name' as host_conn
      from
        exec_command
      where
        command = 'hostname'
    ),
  EOQ
}

query "separate_partition_for_containers_created" {
  sql = <<-EOQ
  ${local.os_hostname_sql}
    linux_output as (
      select
        stdout_output,
        _ctx ->> 'connection_name' as conn
      from
        exec_command,
        os_output
      where
        os_conn = _ctx ->> 'connection_name'
        and command = E'mountpoint -- "$(docker info -f \'{{ .DockerRootDir }}\')"'
    ),
    darwin_output as (
      select
        stdout_output,
        _ctx ->> 'connection_name' as conn
      from
        exec_command,
        os_output
      where
        os_conn = _ctx ->> 'connection_name'
        and os_output.os = 'Darwin'
        and command = E'df | grep "$(docker info -f \'{{ .DockerRootDir }}\')"'
    ),
    command_output as (
      select * from darwin_output
      union all
      select * from linux_output
    )
    select
      host as resource,
      case
        when o.stdout_output = '' or o.stdout_output like '%not a mountpoint%' then 'alarm'
        else 'ok'
      end as status,
      case
        when o.stdout_output = '' or o.stdout_output like '%not a mountpoint%' then host || ' configured Docker root directory is not a mount point.'
        else host || ' configured Docker root directory is a mount point.'
      end as reason
    from
      hostname as h,
      linux_output as o
    where
      conn = host_conn;
  EOQ
}

query "docker_daemon_run_as_root_user" {
  sql = <<-EOQ
    ${local.hostname_sql}
     command_output as (
      select
        stdout_output,
         _ctx ->> 'connection_name' as conn
      from
        exec_command
      where
        command = 'ps -ef | grep dockerd'
    )
    select
      host as resource,
      case
        when o.stdout_output like '%root%' then 'alarm'
        else 'ok'
      end as status,
      case
        when o.stdout_output like '%root%' then host || ' Docker daemon is running as root user.'
        else host || ' Docker daemon is not running as root user.'
      end as reason
    from
      hostname as h,
      command_output as o
    where
      o.conn = host_conn;
  EOQ
}

query "logging_level_set_to_info" {
  sql = <<-EOQ
    ${local.hostname_sql}
     command_output as (
      select
        stdout_output,
         _ctx ->> 'connection_name' as conn
      from
        exec_command
      where
        command = 'ps -ef | grep dockerd'
    )
    select
      host as resource,
      case
        when o.stdout_output like '%--log-level=info%'
        or o.stdout_output not like '%--log-level%' then 'ok'
        else 'alarm'
      end as status,
      case
        when o.stdout_output like '%--log-level=info%'
        or o.stdout_output not like '%--log-level%' then host || ' logging level is not set or set to info.'
        else host || ' logging level is not set to info.'
      end as reason
    from
      hostname as h,
      command_output as o
    where
      o.conn = host_conn;
  EOQ
}

query "docker_daemon_auditing_configured" {
  sql = <<-EOQ
    ${local.os_hostname_sql}
     linux_output as (
      select
        stdout_output,
        _ctx ->> 'connection_name' as conn
      from
        exec_command,
        os_output
      where
        os_conn = _ctx ->> 'connection_name'
        and command = 'echo $(sudo -n auditctl -l | grep /usr/bin/dockerd)'
    )
    select
      host as resource,
      case
        when os.os ilike '%Darwin%' then 'skip'
        when o.stdout_output = '' then 'alarm'
        else 'ok'
      end as status,
      case
        when os.os ilike '%Darwin%' then host || ' /usr/bin/dockerd does not exist on ' || os.os || ' OS.'
        when o.stdout_output = '' then host || ' Docker daemon auditing is not configured.'
        else host || ' Docker daemon auditing is configured.'
      end as reason
    from
      hostname as h,
      os_output as os,
      linux_output as o
    where
      os.os_conn = h.host_conn
      and os.os_conn = o.conn
  EOQ
}

query "docker_socket_file_ownership_set_to_root" {
  sql = <<-EOQ
    ${local.os_hostname_sql}
     linux_output as (
      select
        stdout_output,
        _ctx ->> 'connection_name' as conn
      from
        exec_command,
        os_output
      where
        os_conn = _ctx ->> 'connection_name'
        and command = 'echo $(stat -c %U:%G /usr/lib/systemd/system/docker.socket | grep -v root:root)'
    ),
    linux_file_location as (
      select
        stdout_output,
        _ctx ->> 'connection_name' as conn
      from
        exec_command,
        os_output
      where
        os_conn = _ctx ->> 'connection_name'
        and command = 'echo $(systemctl show -p FragmentPath docker.socket)'
    )
    select
      host as resource,
      case
         when os.os ilike '%Darwin%' then 'skip'
        when l.stdout_output = '' then 'skip'
        when o.stdout_output = '' then 'ok'
        else 'alarm'
      end as status,
      case
        when os.os ilike '%Darwin%' then host || ' docker.socket does not exist on ' || os.os || ' OS.'
        when l.stdout_output = '' then host || ' recommendation is not applicable as the file is unavailable.'
        when o.stdout_output = '' then host || ' file ownership is set to root:root.'
        else host || ' Docker daemon auditing is configured.'
      end as reason
    from
      hostname as h,
      os_output as os,
      linux_output as o,
      linux_file_location as l
    where
      os.os_conn = h.host_conn;
  EOQ
}

query "etc_docker_directory_ownership_set_to_root" {
  sql = <<-EOQ
    ${local.os_hostname_sql}
     linux_output as (
      select
        stdout_output,
        _ctx ->> 'connection_name' as conn
      from
        exec_command,
        os_output
      where
        os_conn = _ctx ->> 'connection_name'
        and command = 'echo $(stat -c %U:%G /etc/docker | grep -v root:root)'
    )
    select
      host as resource,
      case
        when os.os ilike '%Darwin%' then 'skip'
        when o.stdout_output = '' then 'ok'
        else 'alarm'
      end as status,
      case
        when os.os ilike '%Darwin%' then host || ' docker.socket does not exist on ' || os.os || ' OS.'
        when o.stdout_output = '' then host || ' /etc/docker directory ownership is set to root:root.'
        else host || ' /etc/docker directory ownership is not set to root:root.'
      end as reason
    from
      hostname as h,
      os_output as os,
      linux_output as o
    where
      os.os_conn = h.host_conn;
  EOQ
}

query "docker_files_and_directories_run_containerd_auditing_configured" {
  sql = <<-EOQ
    ${local.os_hostname_sql}
    linux_output as (
      select
        stdout_output,
        _ctx ->> 'connection_name' as conn
      from
        exec_command,
        os_output
      where
        os_conn = _ctx ->> 'connection_name'
        and command = 'echo $(sudo -n auditctl -l | grep /run/containerd)'
    )
    select
      host as resource,
      case
        when os.os ilike '%Darwin%' then 'skip'
        when o.stdout_output = '' then 'alarm'
        else 'ok'
      end as status,
      case
        when os.os ilike '%Darwin%' then host || ' /run/containerd does not exist on ' || os.os || ' OS.'
        when o.stdout_output = '' then host || ' Docker files and directories "/run/containerd" auditing is not configured.'
        else host || ' Docker files and directories "/run/containerd" auditing is configured.'
      end as reason
    from
      hostname as h,
      os_output as os,
      linux_output as o
    where
      os.os_conn = h.host_conn;
  EOQ
}

query "docker_files_and_directories_var_lib_docker_auditing_configured" {
  sql = <<-EOQ
    ${local.os_hostname_sql}
    linux_output as (
      select
        stdout_output,
        _ctx ->> 'connection_name' as conn
      from
        exec_command,
        os_output
      where
        os_conn = _ctx ->> 'connection_name'
        and command = 'echo $(sudo -n auditctl -l | grep /var/lib/docker)'
    )
    select
      host as resource,
      case
        when os.os ilike '%Darwin%' then 'skip'
        when o.stdout_output = '' then 'alarm'
        else 'ok'
      end as status,
      case
        when os.os ilike '%Darwin%' then host || ' /var/lib/docker does not exist on ' || os.os || ' OS.'
        when o.stdout_output = '' then host || ' Docker files and directories "/var/lib/docker" auditing is not configured.'
        else host || ' Docker files and directories "/var/lib/docker" auditing is configured.'
      end as reason
    from
      hostname as h,
      os_output as os,
      linux_output as o
    where
      os.os_conn = h.host_conn;
  EOQ
}

query "docker_files_and_directories_etc_docker_auditing_configured" {
  sql = <<-EOQ
    ${local.os_hostname_sql}
    linux_output as (
      select
        stdout_output,
        _ctx ->> 'connection_name' as conn
      from
        exec_command,
        os_output
      where
        os_conn = _ctx ->> 'connection_name'
        and command = 'echo $(sudo -n auditctl -l | grep /etc/docker)'
    )
    select
      host as resource,
      case
        when os.os ilike '%Darwin%' then 'skip'
        when o.stdout_output = '' then 'alarm'
        else 'ok'
      end as status,
      case
        when os.os ilike '%Darwin%' then host || ' /etc/docker does not exist on ' || os.os || ' OS.'
        when o.stdout_output = '' then host || ' Docker files and directories "/etc/docker" auditing is not configured.'
        else host || ' Docker files and directories "/etc/docker" auditing is configured.'
      end as reason
    from
      hostname as h,
      os_output as os,
      linux_output as o
    where
      os.os_conn = h.host_conn;
  EOQ
}

query "docker_files_and_directories_docker_service_auditing_configured" {
  sql = <<-EOQ
    ${local.os_hostname_sql}
    linux_output as (
      select
        stdout_output,
        _ctx ->> 'connection_name' as conn
      from
        exec_command,
        os_output
      where
        os_conn = _ctx ->> 'connection_name'
        and command = 'echo $(sudo -n auditctl -l | grep docker.service)'
    ),
    linux_file_location as (
      select
        stdout_output,
        _ctx ->> 'connection_name' as conn
      from
        exec_command,
        os_output
      where
        os_conn = _ctx ->> 'connection_name'
        and command = 'echo $(systemctl show -p FragmentPath docker.service)'
    )
    select
      host as resource,
      case
        when os.os ilike '%Darwin%' then 'skip'
        when l.stdout_output = '' then 'skip'
        when o.stdout_output = '' then 'alarm'
        else 'ok'
      end as status,
      case
        when os.os ilike '%Darwin%' then host || ' docker.service does not exist on ' || os.os || ' OS.'
        when l.stdout_output = '' then host || ' recommendation is not applicable as the file is unavailable.'
        when o.stdout_output = '' then host || ' Docker files and directories "docker.service" auditing is not configured.'
        else host || ' Docker files and directories "docker.service" auditing is configured.'
      end as reason
    from
      hostname as h,
      os_output as os,
      linux_output as o,
      linux_file_location as l
    where
      os.os_conn = h.host_conn;
  EOQ
}

query "docker_files_and_directories_containerd_sock_auditing_configured" {
  sql = <<-EOQ
    ${local.os_hostname_sql}
      linux_output as (
      select
        stdout_output,
        _ctx ->> 'connection_name' as conn
      from
        exec_command,
        os_output
      where
        os_conn = _ctx ->> 'connection_name'
        and command = 'echo $(sudo -n auditctl -l | grep containerd.sock)'
    ),
    linux_file_location as (
      select
        stdout_output,
        _ctx ->> 'connection_name' as conn
      from
        exec_command,
        os_output
      where
        os_conn = _ctx ->> 'connection_name'
        and command = 'grep ''containerd.sock'' /etc/containerd/config.toml'
    )
    select
      host as resource,
      case
        when os.os ilike '%Darwin%' then 'skip'
        when l.stdout_output = '' then 'skip'
        when o.stdout_output = '' then 'alarm'
        else 'ok'
      end as status,
      case
        when os.os ilike '%Darwin%' then host || ' /etc/containerd/config.toml does not exist on ' || os.os || ' OS.'
        when l.stdout_output = '' then host || ' recommendation is not applicable as the file is unavailable.'
        when o.stdout_output = '' then host || ' Docker files and directories "containerd.sock" auditing is not configured.'
        else host || ' Docker files and directories "containerd.sock" auditing is configured.'
      end as reason
    from
      hostname as h,
      os_output as os,
      linux_output as o,
      linux_file_location as l
    where
      os.os_conn = h.host_conn;
  EOQ
}

query "docker_files_and_directories_docker_socket_auditing_configured" {
  sql = <<-EOQ
    ${local.os_hostname_sql}
    linux_output as (
      select
        stdout_output,
        _ctx ->> 'connection_name' as conn
      from
        exec_command,
        os_output
      where
        os_conn = _ctx ->> 'connection_name'
        and command = 'echo $(sudo -n auditctl -l | grep docker.socket)'
    ),
    linux_file_location as (
      select
        stdout_output,
        _ctx ->> 'connection_name' as conn
      from
        exec_command,
        os_output
      where
        os_conn = _ctx ->> 'connection_name'
        and command = 'echo $(systemctl show -p FragmentPath docker.socket)'
    )
    select
      host as resource,
      case
        when os.os ilike '%Darwin%' then 'skip'
        when l.stdout_output = '' then 'skip'
        when o.stdout_output = '' then 'alarm'
        else 'ok'
      end as status,
      case
        when os.os ilike '%Darwin%' then host || ' docker.socket does not exist on ' || os.os || ' OS.'
        when l.stdout_output = '' then host || ' recommendation is not applicable as the file is unavailable.'
        when o.stdout_output = '' then host || ' Docker files and directories "docker.socket" auditing is not configured.'
        else host || ' Docker files and directories "docker.socket" auditing is configured.'
      end as reason
    from
      hostname as h,
      os_output as os,
      linux_output as o,
      linux_file_location as l
    where
      os.os_conn = h.host_conn;
  EOQ
}

query "docker_files_and_directories_etc_default_docker_auditing_configured" {
  sql = <<-EOQ
    ${local.os_hostname_sql}
    linux_output as (
      select
        stdout_output,
        _ctx ->> 'connection_name' as conn
      from
        exec_command,
        os_output
      where
        os_conn = _ctx ->> 'connection_name'
        and command = 'echo $(sudo -n auditctl -l | grep /etc/default/docker)'
    )
    select
      host as resource,
      case
        when os.os ilike '%Darwin%' then 'skip'
        when o.stdout_output = '' then 'alarm'
        else 'ok'
      end as status,
      case
        when os.os ilike '%Darwin%' then host || ' /etc/default/docker does not exist on ' || os.os || ' OS.'
        when o.stdout_output = '' then host || ' Docker files and directories "/etc/default/docker" auditing is not configured.'
        else host || ' Docker files and directories "/etc/default/docker" auditing is configured.'
      end as reason
    from
      hostname as h,
      os_output as os,
      linux_output as o
    where
      os.os_conn = h.host_conn;
  EOQ
}

query "docker_files_and_directories_etc_docker_daemon_auditing_configured" {
  sql = <<-EOQ
    ${local.os_hostname_sql}
    linux_output as (
      select
        stdout_output,
        _ctx ->> 'connection_name' as conn
      from
        exec_command,
        os_output
      where
        os_conn = _ctx ->> 'connection_name'
        and command = 'echo $(sudo -n auditctl -l | grep /etc/docker/daemon.json)'
    )
    select
      host as resource,
      case
        when os.os ilike '%Darwin%' then 'skip'
        when o.stdout_output = '' then 'alarm'
        else 'ok'
      end as status,
      case
        when os.os ilike '%Darwin%' then host || ' /etc/containerd/config.toml does not exist on ' || os.os || ' OS.'
        when o.stdout_output = '' then host || ' Docker files and directories "/etc/docker/daemon.json" auditing is not configured.'
        else host || ' Docker files and directories "/etc/docker/daemon.json" auditing is configured.'
      end as reason
    from
      hostname as h,
      os_output as os,
      linux_output as o
    where
      os.os_conn = h.host_conn;
  EOQ
}

query "docker_files_and_directories_etc_containerd_config_auditing_configured" {
  sql = <<-EOQ
    ${local.os_hostname_sql}
    linux_output as (
      select
        stdout_output,
        _ctx ->> 'connection_name' as conn
      from
        exec_command,
        os_output
      where
        os_conn = _ctx ->> 'connection_name'
        and command = 'echo $(sudo -n auditctl -l | grep /etc/containerd/config.toml)'
    )
    select
      host as resource,
      case
        when os.os ilike '%Darwin%' then 'skip'
        when o.stdout_output = '' then 'alarm'
        else 'ok'
      end as status,
      case
        when os.os ilike '%Darwin%' then host || ' /etc/containerd/config.toml does not exist on ' || os.os || ' OS.'
        when o.stdout_output = '' then host || ' Docker files and directories "/etc/containerd/config.toml" auditing is not configured.'
        else host || ' Docker files and directories "/etc/containerd/config.toml" auditing is configured.'
      end as reason
    from
      hostname as h,
      os_output as os,
      linux_output as o
    where
      os.os_conn = h.host_conn;
  EOQ
}

query "docker_files_and_directories_etc_sysconfig_docker_auditing_configured" {
  sql = <<-EOQ
    ${local.os_hostname_sql}
    linux_output as (
      select
        stdout_output,
        _ctx ->> 'connection_name' as conn
      from
        exec_command,
        os_output
      where
        os_conn = _ctx ->> 'connection_name'
        and command = 'echo $(sudo -n auditctl -l | grep /etc/sysconfig/docker)'
    )
    select
      host as resource,
      case
        when os.os ilike '%Darwin%' then 'skip'
        when o.stdout_output = '' then 'alarm'
        else 'ok'
      end as status,
      case
        when os.os ilike '%Darwin%' then host || ' /etc/sysconfig/docker does not exist on ' || os.os || ' OS.'
        when o.stdout_output = '' then host || ' Docker files and directories "/etc/sysconfig/docker" auditing is not configured.'
        else host || ' Docker files and directories "/etc/sysconfig/docker" auditing is configured.'
      end as reason
    from
      hostname as h,
      os_output as os,
      linux_output as o
    where
      os.os_conn = h.host_conn;
  EOQ
}

query "docker_files_and_directories_usr_bin_containerd_auditing_configured" {
  sql = <<-EOQ
    ${local.os_hostname_sql}
    linux_output as (
      select
        stdout_output,
        _ctx ->> 'connection_name' as conn
      from
        exec_command,
        os_output
      where
        os_conn = _ctx ->> 'connection_name'
        and command = 'echo $(sudo -n auditctl -l | grep /usr/bin/containerd)'
    )
    select
      host as resource,
      case
        when os.os ilike '%Darwin%' then 'skip'
        when o.stdout_output = '' then 'alarm'
        else 'ok'
      end as status,
      case
        when os.os ilike '%Darwin%' then host || ' /usr/bin/containerd does not exist on ' || os.os || ' OS.'
        when o.stdout_output = '' then host || ' Docker files and directories "/usr/bin/containerd" auditing is not configured.'
        else host || ' Docker files and directories "/usr/bin/containerd" auditing is configured.'
      end as reason
    from
      hostname as h,
      os_output as os,
      linux_output as o
    where
      os.os_conn = h.host_conn;
  EOQ
}

query "docker_files_and_directories_usr_bin_containerd_shim_auditing_configured" {
  sql = <<-EOQ
  ${local.os_hostname_sql}
    linux_output as (
      select
        stdout_output,
        _ctx ->> 'connection_name' as conn
      from
        exec_command,
        os_output
      where
        os_conn = _ctx ->> 'connection_name'
        and command = 'echo $(sudo -n auditctl -l | grep /usr/bin/containerd-shim)'
    )
    select
      host as resource,
      case
        when os.os ilike '%Darwin%' then 'skip'
        when o.stdout_output = '' then 'alarm'
        else 'ok'
      end as status,
      case
        when os.os ilike '%Darwin%' then host || ' /usr/bin/containerd-shim does not exist on ' || os.os || ' OS.'
        when o.stdout_output = '' then host || ' Docker files and directories "/usr/bin/containerd-shim" auditing is not configured.'
        else host || ' Docker files and directories "/usr/bin/containerd-shim" auditing is configured.'
      end as reason
    from
      hostname as h,
      os_output as os,
      linux_output as o
    where
      os.os_conn = h.host_conn;
  EOQ
}

query "docker_files_and_directories_usr_bin_containerd_shim_runc_v1_auditing_configured" {
  sql = <<-EOQ
    ${local.os_hostname_sql}
    linux_output as (
      select
        stdout_output,
        _ctx ->> 'connection_name' as conn
      from
        exec_command,
        os_output
      where
        os_conn = _ctx ->> 'connection_name'
        and command = 'echo $(sudo -n auditctl -l | grep /usr/bin/containerd-shim-runc-v1)'
    )
    select
      host as resource,
      case
        when os.os ilike '%Darwin%' then 'skip'
        when o.stdout_output = '' then 'alarm'
        else 'ok'
      end as status,
      case
        when os.os ilike '%Darwin%' then host || ' /usr/bin/containerd-shim-runc-v1 does not exist on ' || os.os || ' OS.'
        when o.stdout_output = '' then host || ' Docker files and directories "/usr/bin/containerd-shim-runc-v1" auditing is not configured.'
        else host || ' Docker files and directories "/usr/bin/containerd-shim-runc-v1" auditing is configured.'
      end as reason
    from
      hostname as h,
      os_output as os,
      linux_output as o
    where
      os.os_conn = h.host_conn;
  EOQ
}

query "docker_files_and_directories_usr_bin_containerd_shim_runc_v2_auditing_configured" {
  sql = <<-EOQ
    ${local.os_hostname_sql}
    linux_output as (
      select
        stdout_output,
        _ctx ->> 'connection_name' as conn
      from
        exec_command,
        os_output
      where
        os_conn = _ctx ->> 'connection_name'
        and command = 'echo $(sudo -n auditctl -l | grep /usr/bin/containerd-shim-runc-v2)'
    )
    select
      host as resource,
      case
        when os.os ilike '%Darwin%' then 'skip'
        when o.stdout_output = '' then 'alarm'
        else 'ok'
      end as status,
      case
        when os.os ilike '%Darwin%' then host || ' /usr/bin/containerd-shim-runc-v2 does not exist on ' || os.os || ' OS.'
        when o.stdout_output = '' then host || ' Docker files and directories "/usr/bin/containerd-shim-runc-v2" auditing is not configured.'
        else host || ' Docker files and directories "/usr/bin/containerd-shim-runc-v2" auditing is configured.'
      end as reason
    from
      hostname as h,
      os_output as os,
      linux_output as o
    where
      os.os_conn = h.host_conn;
  EOQ
}

query "docker_files_and_directories_usr_bin_runc_auditing_configured" {
  sql = <<-EOQ
    ${local.os_hostname_sql}
    linux_output as (
      select
        stdout_output,
        _ctx ->> 'connection_name' as conn
      from
        exec_command,
        os_output
      where
        os_conn = _ctx ->> 'connection_name'
        and command = 'echo $(sudo -n auditctl -l | grep /usr/bin/runc)'
    )
    select
      host as resource,
      case
        when os.os ilike '%Darwin%' then 'skip'
        when o.stdout_output = '' then 'alarm'
        else 'ok'
      end as status,
      case
        when os.os ilike '%Darwin%' then host || ' /usr/bin/runc does not exist on ' || os.os || ' OS.'
        when o.stdout_output = '' then host || ' Docker files and directories "/usr/bin/runc" auditing is not configured.'
        else host || ' Docker files and directories "/usr/bin/runc" auditing is configured.'
      end as reason
    from
      hostname as h,
      os_output as os,
      linux_output as o
    where
      os.os_conn = h.host_conn;
  EOQ
}

query "docker_container_trust_enabled" {
  sql = <<-EOQ
    ${local.hostname_sql}
    command_output as (
      select
        stdout_output,
        _ctx ->> 'connection_name' as conn
      from
        exec_command
      where
        command = 'echo $DOCKER_CONTENT_TRUST'
    )
    select
      host as resource,
      case
        when o.stdout_output like '%1%' then 'ok'
        else 'alarm'
      end as status,
      case
        when o.stdout_output like '%1%' then host || ' Docker container trust enabled.'
        else host || ' Docker container trust disabled.'
      end as reason
    from
      hostname as h,
      command_output as o
    where
      host_conn = o.conn;
  EOQ
}

query "docker_containerd_socket_file_restrictive_permission" {
  sql = <<-EOQ
    ${local.os_hostname_sql}
    linux_output as (
      select
        stdout_output,
        _ctx ->> 'connection_name' as conn
      from
        exec_command,
        os_output
      where
        os_conn = _ctx ->> 'connection_name'
        and command = 'stat -c %a /run/containerd/containerd.sock'
    )
    select
      host as resource,
      case
        when os.os ilike '%Darwin%' then 'skip'
        when o.stdout_output like '%No such file or directory%' then 'skip'
        when o.stdout_output like '%660%' or o.stdout_output like '%600%' then 'ok'
        else 'alarm'
      end as status,
      case
        when os.os ilike '%Darwin%' then host || ' /run/containerd/containerd.sock does not exist on ' || os.os || ' OS.'
        when o.stdout_output like '%No such file or directory%' then host || ' recommendation is not applicable as the file is unavailable.'
        else host || ' containerd socket file permission set to ' || o.stdout_output || '.'
        end as reason
    from
      hostname as h,
      os_output as os,
      linux_output as o
    where
      os.os_conn = h.host_conn;
  EOQ
}

query "docker_containerd_socket_file_ownership_root_root" {
  sql = <<-EOQ
    ${local.os_hostname_sql}
    linux_output as (
      select
        stdout_output,
        _ctx ->> 'connection_name' as conn
      from
        exec_command,
        os_output
      where
        os_conn = _ctx ->> 'connection_name'
        and command = 'echo $(stat -c %U:%G /run/containerd/containerd.sock | grep -v root:root)'
    )
    select
      host as resource,
      case
        when os.os ilike '%Darwin%' then 'skip'
        when o.stdout_output = '' then 'ok'
        else 'alarm'
      end as status,
      case
        when os.os ilike '%Darwin%' then host || ' /run/containerd/containerd.sock does not exist on ' || os.os || ' OS.'
        when o.stdout_output = '' then host || ' containerd socket file is owned by root and group owned by root.'
        else host || ' containerd socket file is not owned by root.'
      end as reason
    from
      hostname as h,
      os_output as os,
      linux_output as o
    where
      os.os_conn = h.host_conn;
  EOQ
}

query "etc_sysconfig_docker_file_ownership_root_root" {
  sql = <<-EOQ
    ${local.os_hostname_sql}
    linux_output as (
      select
        stdout_output,
        _ctx ->> 'connection_name' as conn
      from
        exec_command,
        os_output
      where
        os_conn = _ctx ->> 'connection_name'
        and command = 'echo $(stat -c %U:%G /etc/sysconfig/docker | grep -v root:root)'
    )
    select
      host as resource,
      case
         when os.os ilike '%Darwin%' then 'skip'
        when o.stdout_output = '' then 'ok'
        else 'alarm'
      end as status,
      case
        when os.os ilike '%Darwin%' then host || ' /etc/sysconfig/docker does not exist on ' || os.os || ' OS.'
        when o.stdout_output = '' then host || ' /etc/sysconfig/docker file ownership is set to root:root.'
        else host || ' /etc/sysconfig/docker file ownership is not set to root:root'
      end as reason
    from
      hostname as h,
      os_output as os,
      linux_output as o
    where
      os.os_conn = h.host_conn;
  EOQ
}

query "etc_sysconfig_docker_file_restrictive_permission" {
  sql = <<-EOQ
    ${local.os_hostname_sql}
    linux_output as (
      select
        stdout_output,
        _ctx ->> 'connection_name' as conn
      from
        exec_command,
        os_output
      where
        os_conn = _ctx ->> 'connection_name'
        and command = 'echo $(stat -c %a /etc/sysconfig/docker)'
    )
    select
      host as resource,
      case
        when os.os ilike '%Darwin%' then 'skip'
        when o.stdout_output like '%No such file or directory%' then 'skip'
        when o.stdout_output like '%644%' then 'ok'
        else 'alarm'
      end as status,
      case
        when os.os ilike '%Darwin%' then host || ' /etc/sysconfig/docker does not exist on ' || os.os || ' OS.'
        when o.stdout_output like '%No such file or directory%' then host || ' recommendation is not applicable as the file is unavailable.'
        else host || ' containerd socket file permission set to ' || o.stdout_output || '.'
      end as reason
    from
      hostname as h,
      os_output as os,
      linux_output as o
    where
      os.os_conn = h.host_conn;
  EOQ
}

query "docker_service_file_ownership_root_root" {
  sql = <<-EOQ
    ${local.os_hostname_sql}
    linux_output as (
      select
        stdout_output,
        _ctx ->> 'connection_name' as conn
      from
        exec_command,
        os_output
      where
        os_conn = _ctx ->> 'connection_name'
        and command = 'echo $(stat -c %U:%G "$(systemctl show -p FragmentPath docker.service | awk -F''='' ''{print $2}'')" | grep -v root:root)'
    ),
    linux_file_location as (
      select
        stdout_output,
        _ctx ->> 'connection_name' as conn
      from
        exec_command,
        os_output
      where
        os_conn = _ctx ->> 'connection_name'
        and command = 'echo $(systemctl show -p FragmentPath docker.service)'
    )
    select
      host as resource,
      case
        when os.os ilike '%Darwin%' then 'skip'
        when l.stdout_output = '' then 'skip'
        when o.stdout_output = '' then 'ok'
        else 'alarm'
      end as status,
      case
        when os.os ilike '%Darwin%' then host || ' docker.service does not exist on ' || os.os || ' OS.'
        when l.stdout_output = '' then host || ' recommendation is not applicable as the file is unavailable.'
        when o.stdout_output = '' then host || ' docker.service file ownership is set to root:root.'
        else host || ' docker.service file ownership is not set to root:root.'
      end as reason
    from
      hostname as h,
      os_output as os,
      linux_output as o,
      linux_file_location as l
    where
      os.os_conn = h.host_conn;
  EOQ
}

query "docker_service_file_restrictive_permission" {
  sql = <<-EOQ
    ${local.os_hostname_sql}
    linux_output as (
      select
        stdout_output,
        _ctx ->> 'connection_name' as conn
      from
        exec_command,
        os_output
      where
        os_conn = _ctx ->> 'connection_name'
        and command = 'echo $(stat -c %a "$(systemctl show -p FragmentPath docker.service | awk -F''='' ''{print $2}'')")'
    ),
    linux_file_location as (
      select
        stdout_output,
        _ctx ->> 'connection_name' as conn
      from
        exec_command,
        os_output
      where
        os_conn = _ctx ->> 'connection_name'
        and command = 'echo $(systemctl show -p FragmentPath docker.service)'
    )
    select
      host as resource,
      case
        when os.os ilike '%Darwin%' then 'skip'
        when l.stdout_output = '' then 'skip'
        when o.stdout_output like '%644%' then 'ok'
        else 'alarm'
      end as status,
      case
        when os.os ilike '%Darwin%' then host || ' docker.service does not exist on ' || os.os || ' OS.'
        when l.stdout_output = '' then host || ' recommendation is not applicable as the file is unavailable.'
        else  host || ' docker.service file permission set to ' || o.stdout_output || '.'
      end as reason
    from
      hostname as h,
      os_output as os,
      linux_output as o,
      linux_file_location as l
    where
      os.os_conn = h.host_conn;
  EOQ
}

query "docker_socket_file_restrictive_permission" {
  sql = <<-EOQ
    ${local.os_hostname_sql}
    linux_output as (
      select
        stdout_output,
        _ctx ->> 'connection_name' as conn
      from
        exec_command,
        os_output
      where
        os_conn = _ctx ->> 'connection_name'
        and command = 'echo $(stat -c %a "$(systemctl show -p FragmentPath docker.socket | awk -F''='' ''{print $2}'')")'
    ),
    linux_file_location as (
      select
        stdout_output,
        _ctx ->> 'connection_name' as conn
      from
        exec_command,
        os_output
      where
        os_conn = _ctx ->> 'connection_name'
        and command = 'echo $(systemctl show -p FragmentPath docker.socket)'
    )
    select
      host as resource,
      case
        when os.os ilike '%Darwin%' then 'skip'
        when l.stdout_output = '' then 'skip'
        when o.stdout_output like '%644%' then 'ok'
        else 'alarm'
      end as status,
      case
        when os.os ilike '%Darwin%' then host || ' docker.socket does not exist on ' || os.os || ' OS.'
        when l.stdout_output = '' then host || ' recommendation is not applicable as the file is unavailable.'
        else  host || ' docker.socket file permission set to ' || o.stdout_output || '.'
      end as reason
    from
      hostname as h,
      os_output as os,
      linux_output as o,
      linux_file_location as l
    where
      os.os_conn = h.host_conn;
  EOQ
}

query "etc_docker_directory_restrictive_permission" {
  sql = <<-EOQ
    ${local.os_hostname_sql}
    linux_output as (
      select
        stdout_output,
        _ctx ->> 'connection_name' as conn
      from
        exec_command,
        os_output
      where
        os_conn = _ctx ->> 'connection_name'
        and command = 'echo $(stat -c %a /etc/docker)'
    )
    select
      host as resource,
      case
        when os.os ilike '%Darwin%' then 'skip'
        when o.stdout_output like '%No such file or directory%' then 'skip'
        when o.stdout_output like '%755%' then 'ok'
        else 'alarm'
      end as status,
      case
        when os.os ilike '%Darwin%' then host || ' /etc/docker does not exist on ' || os.os || ' OS.'
        when o.stdout_output like '%No such file or directory%' then host || ' recommendation is not applicable as the file is unavailable.'
        else host || ' /etc/docker directory permission set to ' || o.stdout_output || '.'
        end as reason
    from
      hostname as h,
      os_output as os,
      linux_output as o
    where
      os.os_conn = h.host_conn;
  EOQ
}

query "tls_ca_certificate_ownership_root_root" {
  sql = <<-EOQ
    ${local.os_hostname_sql}
    linux_output as (
      with json_value_cte as (
        select
          'stat -c %U:%G ' || (stdout_output::jsonb->>'tlscacert') || ' | grep -v root:root' as key_value,
          _ctx ->> 'connection_name' as os_conn
        from
          exec_command,
          os_output
        where
          os_conn = _ctx ->> 'connection_name'
          and command = 'cat /etc/docker/daemon.json'
        order by
          key_value
      )
      select
        stdout_output,
        _ctx ->> 'connection_name' as conn
      from
        json_value_cte as a
      join
        exec_command
        on command = a.key_value
      where
        os_conn = _ctx ->> 'connection_name'
    )
    select
      host as resource,
      case
        when os.os ilike '%Darwin%' then 'skip'
        when o.stdout_output like '' then 'ok'
        else 'alarm'
      end as status,
      case
        when os.os ilike '%Darwin%' then host || ' /etc/docker/daemon.json does not exist on ' || os.os || ' OS.'
        when o.stdout_output like '' then host || ' TLS CA certificate file ownership is set to root:root.'
        else host || ' TLS CA certificate file ownership is set to ' || o.stdout_output || '.'
        end as reason
    from
      hostname as h,
      os_output as os,
      linux_output as o
    where
      os.os_conn = h.host_conn;
  EOQ
}

query "tls_ca_certificate_permission_444" {
  sql = <<-EOQ
    ${local.os_hostname_sql}
    linux_output as (
      with json_value_cte as (
        select
          'stat -c %a ' || (stdout_output::jsonb->>'tlscacert') as key_value,
          _ctx ->> 'connection_name' as os_conn
        from
          exec_command,
          os_output
        where
          os_conn = _ctx ->> 'connection_name'
          and command = 'cat /etc/docker/daemon.json'
        order by
          key_value
      )
      select
        stdout_output,
        _ctx ->> 'connection_name' as conn
      from
        json_value_cte as a
      join
        exec_command
        on command = a.key_value
      where
        os_conn = _ctx ->> 'connection_name'
    )
    select
      host as resource,
      case
        when os.os ilike '%Darwin%' then 'skip'
        when o.stdout_output like '%444%' then 'ok'
        else 'alarm'
      end as status,
      case
        when os.os ilike '%Darwin%' then host || ' /etc/docker/daemon.json does not exist on ' || os.os || ' OS.'
        when o.stdout_output like '%444%' then host || ' TLS CA certificate file permissions are set to 444.'
        else host || ' TLS CA certificate file permissions are set to ' || o.stdout_output || '.'
        end as reason
    from
      hostname as h,
      os_output as os,
      linux_output as o
    where
      os.os_conn = h.host_conn;
  EOQ
}

query "docker_server_certificate_ownership_root_root" {
  sql = <<-EOQ
    ${local.os_hostname_sql}
    linux_output as (
      with json_value_cte as (
        select
          'stat -c %U:%G ' || (stdout_output::jsonb->>'tlscert') || ' | grep -v root:root' as key_value,
          _ctx ->> 'connection_name' as os_conn
        from
          exec_command,
          os_output
        where
          os_conn = _ctx ->> 'connection_name'
          and command = 'cat /etc/docker/daemon.json'
        order by
          key_value
      )
      select
        stdout_output,
        _ctx ->> 'connection_name' as conn
      from
        json_value_cte as a
      join
        exec_command
        on command = a.key_value
      where
        os_conn = _ctx ->> 'connection_name'
    )
    select
      host as resource,
      case
        when os.os ilike '%Darwin%' then 'skip'
        when o.stdout_output like '' then 'ok'
        else 'alarm'
      end as status,
      case
        when os.os ilike '%Darwin%' then host || ' /etc/docker/daemon.json does not exist on ' || os.os || ' OS.'
        when o.stdout_output like '' then host || ' server certificate file ownership is set to root:root.'
        else host || ' server certificate file ownership is set to ' || o.stdout_output || '.'
        end as reason
    from
      hostname as h,
      os_output as os,
      linux_output as o
    where
      os.os_conn = h.host_conn;
  EOQ
}

query "docker_server_certificate_permission_444" {
  sql = <<-EOQ
    ${local.os_hostname_sql}
    linux_output as (
      with json_value_cte as (
        select
          'stat -c %a ' || (stdout_output::jsonb->>'tlscert') as key_value,
          _ctx ->> 'connection_name' as os_conn
        from
          exec_command,
          os_output
        where
          os_conn = _ctx ->> 'connection_name'
          and command = 'cat /etc/docker/daemon.json'
        order by
          key_value
      )
      select
        stdout_output,
        _ctx ->> 'connection_name' as conn
      from
        json_value_cte as a
      join
        exec_command
        on command = a.key_value
      where
        os_conn = _ctx ->> 'connection_name'
    )
    select
      host as resource,
      case
        when os.os ilike '%Darwin%' then 'skip'
        when o.stdout_output like '%444%' then 'ok'
        else 'alarm'
      end as status,
      case
        when os.os ilike '%Darwin%' then host || ' /etc/docker/daemon.json does not exist on ' || os.os || ' OS.'
        when o.stdout_output like '%444%' then host || ' server certificate file permissions are set to 444.'
        else host || ' server certificate file permissions are set to ' || o.stdout_output || '.'
        end as reason
    from
      hostname as h,
      os_output as os,
      linux_output as o
    where
      os.os_conn = h.host_conn;
  EOQ
}

query "docker_server_certificate_key_ownership_root_root" {
  sql = <<-EOQ
    ${local.os_hostname_sql}
    linux_output as (
      with json_value_cte as (
        select
          'stat -c %U:%G ' || (stdout_output::jsonb->>'tlskey') || ' | grep -v root:root' as key_value,
          _ctx ->> 'connection_name' as os_conn
        from
          exec_command,
          os_output
        where
          os_conn = _ctx ->> 'connection_name'
          and command = 'cat /etc/docker/daemon.json'
        order by
          key_value
      )
      select
        stdout_output,
        _ctx ->> 'connection_name' as conn
      from
        json_value_cte as a
      join
        exec_command
        on command = a.key_value
      where
        os_conn = _ctx ->> 'connection_name'
    )
    select
      host as resource,
      case
        when os.os ilike '%Darwin%' then 'skip'
        when o.stdout_output like '' then 'ok'
        else 'alarm'
      end as status,
      case
        when os.os ilike '%Darwin%' then host || ' /etc/docker/daemon.json does not exist on ' || os.os || ' OS.'
        when o.stdout_output like '' then host || ' server certificate key file ownership is set to root:root.'
        else host || ' server certificate key file ownership is set to ' || o.stdout_output || '.'
        end as reason
    from
      hostname as h,
      os_output as os,
      linux_output as o
    where
      os.os_conn = h.host_conn;
  EOQ
}

query "docker_server_certificate_key_permission_400" {
  sql = <<-EOQ
    ${local.os_hostname_sql}
    linux_output as (
      with json_value_cte as (
        select
          'stat -c %a ' || (stdout_output::jsonb->>'tlskey') as key_value,
          _ctx ->> 'connection_name' as os_conn
        from
          exec_command,
          os_output
        where
          os_conn = _ctx ->> 'connection_name'
          and command = 'cat /etc/docker/daemon.json'
        order by
          key_value
      )
      select
        stdout_output,
        _ctx ->> 'connection_name' as conn
      from
        json_value_cte as a
      join
        exec_command
        on command = a.key_value
      where
        os_conn = _ctx ->> 'connection_name'
    )
    select
      host as resource,
      case
        when os.os ilike '%Darwin%' then 'skip'
        when o.stdout_output like '%400%' then 'ok'
        else 'alarm'
      end as status,
      case
        when os.os ilike '%Darwin%' then host || ' /etc/docker/daemon.json does not exist on ' || os.os || ' OS.'
        when o.stdout_output like '%400%' then host || ' server certificate key file permissions are set to 400.'
        else host || ' server certificate key file permissions are set to ' || o.stdout_output || '.'
        end as reason
    from
      hostname as h,
      os_output as os,
      linux_output as o
    where
      os.os_conn = h.host_conn;
  EOQ
}

query "docker_socket_file_ownership_root_docker" {
  sql = <<-EOQ
    ${local.os_hostname_sql}
    linux_output as (
      select
        stdout_output,
        _ctx ->> 'connection_name' as conn
      from
        exec_command,
        os_output
      where
        os_conn = _ctx ->> 'connection_name'
        and command = 'stat -c %U:%G /var/run/docker.sock | grep -v root:docker'
    ),
    darwin_output as (
      select
        stdout_output,
        _ctx ->> 'connection_name' as conn
      from
        exec_command,
        os_output
      where
        os_conn = _ctx ->> 'connection_name'
        and os_output.os = 'Darwin'
        and command = 'stat -f %Su:%Sg /var/run/docker.sock | grep -v root:docker'
    ),
    command_output as (
      select * from darwin_output
      union all
      select * from linux_output
    )
    select
      host as resource,
      case
        when o.stdout_output = '' then 'ok'
        else 'alarm'
      end as status,
      case
        when o.stdout_output = '' then host || ' Docker socket file ownership is set to root:docker.'
        else host || ' Docker socket file ownership is not set to root:docker.'
      end as reason
    from
      hostname as h,
      os_output as os,
      command_output as o
    where
      os.os_conn = h.host_conn;
  EOQ
}

query "docker_sock_file_restrictive_permission" {
  sql = <<-EOQ
    ${local.os_hostname_sql}
     linux_output as (
      select
        stdout_output,
        _ctx ->> 'connection_name' as conn
      from
        exec_command,
        os_output
      where
        os_conn = _ctx ->> 'connection_name'
        and command = 'stat -c %a /var/run/docker.sock'
    ),
    darwin_output as (
      select
        stdout_output,
        _ctx ->> 'connection_name' as conn
      from
        exec_command,
        os_output
      where
        os_conn = _ctx ->> 'connection_name'
        and os_output.os = 'Darwin'
        and command = 'stat -f %Op /var/run/docker.sock'
    ),
    command_output as (
      select * from darwin_output
      union all
      select * from linux_output
    )
    select
      host as resource,
      case
        when o.stdout_output like '%No such file or directory%' then 'skip'
        when o.stdout_output like '%660%' then 'ok'
        else 'alarm'
      end as status,
      case
        when o.stdout_output like host || '%No such file or directory%' then ' recommendation is not applicable as the file is unavailable.'
        else host || ' docker.socket file permission set to ' || o.stdout_output || '.'
      end as reason
    from
      hostname as h,
      os_output as os,
      command_output as o
    where
      os.os_conn = h.host_conn;
  EOQ
}

query "daemon_json_file_ownership_root_root" {
  sql = <<-EOQ
    ${local.os_hostname_sql}
    linux_output as (
      select
        stdout_output,
        _ctx ->> 'connection_name' as conn
      from
        exec_command,
        os_output
      where
        os_conn = _ctx ->> 'connection_name'
        and command = 'echo $(stat -c %U:%G /etc/docker/daemon.json | grep -v root:root)'
    )
    select
      host as resource,
      case
        when os.os ilike '%Darwin%' then 'skip'
        when o.stdout_output like '%No such file or directory%' then 'skip'
        when o.stdout_output = '' then 'ok'
        else 'alarm'
      end as status,
      case
        when os.os ilike '%Darwin%' then host || ' /etc/docker/daemon.json does not exist on ' || os.os || ' OS.'
        when o.stdout_output like '%No such file or directory%' then host || ' recommendation is not applicable as the file is unavailable.'
        when o.stdout_output = '' then host || ' daemon.json file ownership is set to root:root.'
        else host || ' Docker socket file ownership is not set to root:root.'
      end as reason
    from
      hostname as h,
      os_output as os,
      linux_output as o
    where
      os.os_conn = h.host_conn;
  EOQ
}

query "daemon_json_file_restrictive_permission" {
  sql = <<-EOQ
    ${local.os_hostname_sql}
    linux_output as (
      select
        stdout_output,
        _ctx ->> 'connection_name' as conn
      from
        exec_command,
        os_output
      where
        os_conn = _ctx ->> 'connection_name'
        and command = 'stat -c %a /etc/docker/daemon.json'
    )
    select
      host as resource,
      case
        when os.os ilike '%Darwin%' then 'skip'
        when o.stdout_output like '%No such file or directory%' then 'skip'
        when o.stdout_output like '%644%' then 'ok'
        else 'alarm'
      end as status,
      case
        when os.os ilike '%Darwin%' then host || ' /etc/docker/daemon.json does not exist on ' || os.os || ' OS.'
        when o.stdout_output like '%No such file or directory%' then host || ' recommendation is not applicable as the file is unavailable.'
        else host || ' daemon.json file permission set to ' || o.stdout_output || '.'
      end as reason
    from
      hostname as h,
      os_output as os,
      linux_output as o
    where
      os.os_conn = h.host_conn;
  EOQ
}

query "etc_default_docker_file_ownership_root_root" {
  sql = <<-EOQ
    ${local.os_hostname_sql}
    linux_output as (
      select
        stdout_output,
        _ctx ->> 'connection_name' as conn
      from
        exec_command,
        os_output
      where
        os_conn = _ctx ->> 'connection_name'
        and command = 'stat -c %U:%G /etc/default/docker | grep -v root:root'
    )
    select
      host as resource,
      case
        when os.os ilike '%Darwin%' then 'skip'
        when o.stdout_output like '%No such file or directory%' then 'skip'
        when o.stdout_output = '' then 'ok'
        else 'alarm'
      end as status,
      case
        when os.os ilike '%Darwin%' then host || ' /etc/default/docker does not exist on ' || os.os || ' OS.'
        when o.stdout_output like '%No such file or directory%' then host || ' recommendation is not applicable as the file is unavailable.'
        when o.stdout_output = '' then host || ' /etc/default/docker file ownership is set to root:root.'
        else host || ' /etc/default/docker file ownership is not set to root:root.'
      end as reason
    from
      hostname as h,
      os_output as os,
      linux_output as o
    where
      os.os_conn = h.host_conn;
  EOQ
}

query "etc_default_docker_file_restrictive_permission" {
  sql = <<-EOQ
    ${local.os_hostname_sql}
    linux_output as (
      select
        stdout_output,
        _ctx ->> 'connection_name' as conn
      from
        exec_command,
        os_output
      where
        os_conn = _ctx ->> 'connection_name'
        and command = 'stat -c %a /etc/default/docker'
    )
    select
      host as resource,
      case
        when os.os ilike '%Darwin%' then 'skip'
        when o.stdout_output like '%No such file or directory%' then 'skip'
        when o.stdout_output like '%644%' then 'ok'
        else 'alarm'
      end as status,
      case
        when os.os ilike '%Darwin%' then host || ' /etc/default/docker does not exist on ' || os.os || ' OS.'
        when o.stdout_output like '%No such file or directory%' then host || ' recommendation is not applicable as the file is unavailable.'
        else host || ' /etc/default/docker file permission set to ' || o.stdout_output || '.'
      end as reason
    from
      hostname as h,
      os_output as os,
      linux_output as o
    where
      os.os_conn = h.host_conn;
  EOQ
}

query "docker_exec_command_no_privilege_option" {
  sql = <<-EOQ
    ${local.os_hostname_sql}
    linux_output as (
      select
        stdout_output,
        _ctx ->> 'connection_name' as conn
      from
        exec_command,
        os_output
      where
        os_conn = _ctx ->> 'connection_name'
        and command = 'sudo -n ausearch -k docker | grep exec | grep privileged'
    )
    select
      host as resource,
      case
        when os.os ilike '%Darwin%' then 'skip'
        when o.stdout_output like '' then 'ok'
        else 'alarm'
      end as status,
      case
        when os.os ilike '%Darwin%' then host || ' ausearch command does not support on ' || os.os || ' OS.'
        when o.stdout_output like '' then host || ' Docker exec commands are not used with the privileged option.'
        else host || ' Docker exec commands are used with the privileged option.'
      end as reason
    from
      hostname as h,
      os_output as os,
      linux_output as o
    where
      os.os_conn = h.host_conn;
  EOQ
}

query "docker_exec_command_no_user_root_option" {
  sql = <<-EOQ
    ${local.os_hostname_sql}
    linux_output as (
      select
        stdout_output,
        _ctx ->> 'connection_name' as conn
      from
        exec_command,
        os_output
      where
        os_conn = _ctx ->> 'connection_name'
        and command = 'sudo -n ausearch -k docker | grep exec | grep user'
    )
    select
      host as resource,
      case
        when os.os ilike '%Darwin%' then 'skip'
        when o.stdout_output like '' then 'ok'
        else 'alarm'
      end as status,
      case
        when os.os ilike '%Darwin%' then host || ' ausearch command does not support on ' || os.os || ' OS.'
        when o.stdout_output like '' then host || ' Docker exec commands are not used with the user=root option'
        else host || ' Docker exec commands are used with the user=root option.'
      end as reason
    from
      hostname as h,
      os_output as os,
      linux_output as o
    where
      os.os_conn = h.host_conn;
  EOQ
}

query "registry_certificate_ownership_root_root" {
  sql = <<-EOQ
    ${local.os_hostname_sql}
     linux_output as (
      select
        stdout_output,
        _ctx ->> 'connection_name' as conn
      from
        exec_command,
        os_output
      where
        os_conn = _ctx ->> 'connection_name'
        and command = 'echo $(stat -c %U:%G /etc/docker/certs.d/* | grep -v root:root)'
    )
    select
      host as resource,
      case
        when os.os ilike '%Darwin%' then 'skip'
        when o.stdout_output = '' then 'ok'
        else 'alarm'
      end as status,
      case
        when os.os ilike '%Darwin%' then host || ' /etc/docker/certs.d does not exist on ' || os.os || ' OS.'
        when o.stdout_output = '' then host || ' registry certificate file ownership is set to root:root.'
        else host || ' registry certificate file ownership is not set to root:root.'
      end as reason
    from
      hostname as h,
      os_output as os,
      linux_output as o
    where
      os.os_conn = h.host_conn;
  EOQ
}

query "registry_certificate_file_permissions_444" {
  sql = <<-EOQ
    ${local.os_hostname_sql}
    linux_output as (
      select
        stdout_output,
        _ctx ->> 'connection_name' as conn
      from
        exec_command,
        os_output
      where
        os_conn = _ctx ->> 'connection_name'
        and command = 'find /etc/docker/certs.d/ -type f -exec stat -c "%a %n" {} \;'
    )
    select
      host as resource,
      case
        when os.os ilike '%Darwin%' then 'skip'
        when o.stdout_output like '%No such file or directory%' then 'skip'
        when o.stdout_output like '%444%' then 'ok'
        else 'alarm'
      end as status,
      case
        when os.os ilike '%Darwin%' then host || ' /etc/docker/certs.d does not exist on ' || os.os || ' OS.'
        when o.stdout_output like '%No such file or directory%' then host || ' recommendation is not applicable as the file is unavailable.'
        else host || ' registry certificate file permissions set to ' || o.stdout_output || '.'
      end as reason
    from
      hostname as h,
      os_output as os,
      linux_output as o
    where
      os.os_conn = h.host_conn;
  EOQ
}

query "docker_iptables_not_set" {
  sql = <<-EOQ
    ${local.hostname_sql}
     command_output as (
        select
          stdout_output,
          _ctx ->> 'connection_name' as conn
        from
          exec_command
        where
          command = 'ps -ef | grep dockerd'
    )
    select
      host as resource,
      case
        when o.stdout_output like '%--iptables=false%' then 'ok'
        when o.stdout_output not like '%--iptables%' then 'ok'
        else 'alarm'
      end as status,
      case
        when o.stdout_output like '%--iptables=false%' then host || ' iptables is set to false.'
        when o.stdout_output not like '%--iptables%' then host || ' iptables not set.'
        else host || ' iptables are set to true.'
      end as reason
    from
      hostname as h,
      command_output as o
    where
      o.conn = host_conn;
  EOQ
}

query "tls_authentication_docker_daemon_configured" {
  sql = <<-EOQ
    ${local.os_hostname_sql}
    linux_output as (
      select
        stdout_output,
        _ctx ->> 'connection_name' as conn
      from
        exec_command,
        os_output
      where
        os_conn = _ctx ->> 'connection_name'
        and command = 'cat /etc/docker/daemon.json'
    )
    select
      host as resource,
      case
        when os.os ilike '%Darwin%' then 'skip'
        when o.stdout_output::jsonb->>'hosts' not like '%tcp%' then 'info'
        when o.stdout_output::jsonb->>'tlsverify' = 'true'
          and o.stdout_output::jsonb->>'tlscacert' <> ''
          and o.stdout_output::jsonb->>'tlscert' <> ''
          and o.stdout_output::jsonb->>'tlskey' <> '' then 'ok'
        else 'alarm'
      end as status,
      case
        when os.os ilike '%Darwin%' then host || ' /etc/docker/daemon.json does not exist on ' || os.os || ' OS.'
        when o.stdout_output::jsonb->>'hosts' not like '%tcp%' then host || ' Docker daemon not listening on TCP.'
        when o.stdout_output::jsonb->>'tlsverify' = 'true'
          and o.stdout_output::jsonb->>'tlscacert' <> ''
          and o.stdout_output::jsonb->>'tlscert' <> ''
          and o.stdout_output::jsonb->>'tlskey' <> '' then host || ' TLS authentication for Docker daemon is configured.'
        else host || ' TLS authentication for Docker daemon is not configured.'
      end as reason
    from
      hostname as h,
      os_output as os,
      linux_output as o
    where
      os.os_conn = h.host_conn;
  EOQ
}

query "default_ulimit_configured" {
  sql = <<-EOQ
    ${local.os_hostname_sql}
     command_output as (
      select
        stdout_output,
        _ctx ->> 'connection_name' as conn
      from
        exec_command,
        os_output
      where
        os_conn = _ctx ->> 'connection_name'
        and command = 'ps -ef | grep dockerd'
    ), linux_output as (
      select
        stdout_output,
        _ctx ->> 'connection_name' as conn
      from
        exec_command,
        os_output
      where
        os_conn = _ctx ->> 'connection_name'
        and command = 'cat /etc/docker/daemon.json'
    )
    select
      host as resource,
      case
        when os.os ilike '%Darwin%' then 'skip'
        when o.stdout_output like '%--default-ulimit%' or j.stdout_output::jsonb ->> 'default-ulimit' <> '' then 'ok'
        else 'alarm'
      end as status,
      case
        when os.os ilike '%Darwin%' then host || ' /etc/docker/daemon.json does not exist on ' || os.os || ' OS.'
        when o.stdout_output like '%--default-ulimit%' or j.stdout_output::jsonb ->> 'default-ulimit' <> '' then host || ' Default ulimit is set.'
        else host || ' Default ulimit is not set.'
      end as reason
    from
      hostname as h,
      os_output as os,
      command_output as o,
      linux_output as j
    where
      os.os_conn = h.host_conn;
  EOQ
}

query "base_device_size_changed" {
  sql = <<-EOQ
    ${local.os_hostname_sql}
     command_output as (
      select
        stdout_output,
        _ctx ->> 'connection_name' as conn
      from
        exec_command,
        os_output
      where
         os_conn = _ctx ->> 'connection_name'
        and command = 'ps -ef | grep dockerd'
    ), linux_output as (
      select
        stdout_output,
        _ctx ->> 'connection_name' as conn
      from
        exec_command,
        os_output
      where
        os_conn = _ctx ->> 'connection_name'
        and command = 'cat /etc/docker/daemon.json'
    )
    select
      host as resource,
      case
        when os.os ilike '%Darwin%' then 'skip'
        when o.stdout_output not like '%--storage-opt dm.basesize%' or j.stdout_output::jsonb->>'storage-opts' not like '%dm.basesize%' then 'ok'
        else 'alarm'
      end as status,
      case
        when os.os ilike '%Darwin%' then host || ' /etc/docker/daemon.json does not exist on ' || os.os || ' OS.'
        when o.stdout_output not like '%--storage-opt dm.basesize%' or j.stdout_output::jsonb ->> 'storage-opts' not like '%dm.basesize%' then host || ' Default base device size is set.'
        else host || ' Base device size is changed.'
      end as reason
    from
      hostname as h,
      os_output as os,
      command_output as o,
      linux_output as j
    where
      os.os_conn = h.host_conn;
  EOQ
}

query "authorization_docker_client_command_enabled" {
  sql = <<-EOQ
    ${local.os_hostname_sql}
     command_output as (
      select
        stdout_output,
        _ctx ->> 'connection_name' as conn
      from
        exec_command,
        os_output
      where
         os_conn = _ctx ->> 'connection_name'
        and command = 'ps -ef | grep dockerd'
    ), linux_output as (
      select
        stdout_output,
        _ctx ->> 'connection_name' as conn
      from
        exec_command,
        os_output
      where
        os_conn = _ctx ->> 'connection_name'
        and command = 'cat /etc/docker/daemon.json'
    )
    select
      host as resource,
      case
        when os.os ilike '%Darwin%' then 'skip'
        when o.stdout_output like '%--authorization-plugin%' or j.stdout_output::jsonb -> 'authorization-plugins' is not null then 'ok'
        else 'alarm'
      end as status,
      case
        when os.os ilike '%Darwin%' then host || ' /etc/docker/daemon.json does not exist on ' || os.os || ' OS.'
        when o.stdout_output like '%--authorization-plugin%' or j.stdout_output::jsonb -> 'authorization-plugins' is not null then host || ' authorization for Docker client commands is enabled.'
        else host || ' authorization for Docker client commands is disabled.'
      end as reason
    from
      hostname as h,
      os_output as os,
      command_output as o,
      linux_output as j
    where
      os.os_conn = h.host_conn;
  EOQ
}

query "swarm_services_bound_to_specific_host_interface" {
  sql = <<-EOQ
    ${local.hostname_sql}
    command_output as (
      select
        stdout_output,
        _ctx ->> 'connection_name' as conn
      from
        exec_command
      where
        command = 'docker info 2>/dev/null | grep -e "Swarm:*\sactive\s*"'
    ),
    json_output as (
      select
        e.stdout_output,
        _ctx ->> 'connection_name' as conn
      from
        exec_command as e,
        command_output as c
      where
        c.conn = _ctx ->> 'connection_name'
        and c.stdout_output <> ''
        and command = 'netstat -lnt | grep -e ''\\[::]:2377 '' -e '':::2377'' -e ''*:2377 '' -e '' 0\.0\.0\.0:2377 '''
    )
    select
      host as resource,
      case
        when o.stdout_output = '' then 'ok'
        when j.stdout_output <> '' then 'ok'
        else 'alarm'
      end as status,
      case
        when o.stdout_output = '' then host || ' Swarm mode not enabled'
        when j.stdout_output <> '' then host || ' swarm services are bound to a specific host interface.'
        else host || ' swarm services are not bound to a specific host interface.'
      end as reason
    from
      hostname as h,
      command_output as o,
      json_output as j
    where
      host_conn = o.conn;
  EOQ
}

query "docker_socket_not_mounted_inside_containers" {
  sql = <<-EOQ
   ${local.hostname_sql}
    command_output as (
      select
        stdout_output,
        _ctx ->> 'connection_name' as conn
      from
        exec_command
      where
        command = 'echo $(docker ps --quiet --all | xargs docker inspect --format ''{{ .Id }}: Volumes={{ .Mounts }}'' | grep docker.sock)'
    )
    select
      host as resource,
      case
        when o.stdout_output = '' then 'ok'
        else 'alarm'
      end as status,
      case
        when o.stdout_output = '' then host || ' Docker socket is not mounted inside any containers.'
        else host || ' Docker socket is mounted inside ' || o.stdout_output || '.'
      end as reason
    from
      hostname as h,
      command_output as o
    where
      host_conn = o.conn;
  EOQ
}

query "userland_proxy_disabled" {
  sql = <<-EOQ
    ${local.hostname_sql}
     command_output as (
      select
        stdout_output,
         _ctx ->> 'connection_name' as conn
      from
        exec_command
      where
        command = 'ps -ef | grep dockerd'
    )
    select
      host as resource,
      case
        when o.stdout_output like '%--userland-proxy=false%' then 'ok'
        else 'alarm'
      end as status,
      case
        when o.stdout_output like '%--userland-proxy=false%' then host || ' userland proxy is Disabled.'
        else host || ' userland proxy is enabled.'
      end as reason
    from
      hostname as h,
      command_output as o
    where
      host_conn = o.conn;
  EOQ
}

query "containers_no_new_privilege_disabled" {
  sql = <<-EOQ
    ${local.hostname_sql}
     command_output as (
      select
        stdout_output,
         _ctx ->> 'connection_name' as conn
      from
        exec_command
      where
        command = 'ps -ef | grep dockerd'
    )
    select
      host as resource,
      case
        when o.stdout_output like '%--no-new-privileges=false%' then 'alarm'
        when o.stdout_output not like '%--no-new-privileges%' then 'alarm'
        else 'ok'
      end as status,
      case
        when o.stdout_output like '%--no-new-privileges=false%' then host || ' no new privileges is disabled.'
        when o.stdout_output not like '%--no-new-privileges%' then host || ' no new privileges not set.'
        else host || ' no new privilege is enabled.'
      end as reason
    from
      hostname as h,
      command_output as o
    where
      host_conn = o.conn;
  EOQ
}
