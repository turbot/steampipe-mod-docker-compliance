query "container_non_root_user" {
  sql = <<-EOQ
    with dockerfile_user as (
      select
        distinct path
      from
        dockerfile_instruction
      where
        instruction = 'user'
    )select
      distinct i.path as resource,
      case
        when u.path is null then 'alarm'
        else 'ok'
      end as status,
      case
        when u.path is null then 'Dockerfile does not contains the user information.'
        else 'Dockerfile contains the user information.'
      end as reason
    from
      dockerfile_instruction as i
      left join dockerfile_user as u
      on i.path = u.path;
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


