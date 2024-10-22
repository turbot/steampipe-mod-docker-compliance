// Benchmarks and controls for specific services should override the "service" tag
locals {
  docker_compliance_common_tags = {
    category = "Compliance"
    plugin   = "docker"
    service  = "Docker"
  }
}

variable "benchmark_plugins" {
  type        = list(string)
  description = "Controls using tables from these plugins will be included when running benchmarks. Valid values are 'docker' and 'exec'."
  default     = ["docker", "exec"]
}

variable "common_dimensions" {
  type        = list(string)
  description = "A list of common dimensions to add to each control."
  # Define which common dimensions should be added to each control.
  # - connection_name (_ctx ->> 'connection_name')
  default = ["connection_name"]
}

locals {
  # Local internal variable to build the SQL select clause for common
  # dimensions using a table name qualifier if required. Do not edit directly.
  common_dimensions_qualifier_sql = <<-EOQ
  %{~if contains(var.common_dimensions, "connection_name")}, __QUALIFIER___ctx ->> 'connection_name' as connection_name%{endif~}
  EOQ
}

locals {
  # Local internal variable with the full SQL select clause for common
  # dimensions. Do not edit directly.
  common_dimensions_sql = replace(local.common_dimensions_qualifier_sql, "__QUALIFIER__", "")
}
