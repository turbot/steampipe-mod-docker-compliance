// Benchmarks and controls for specific services should override the "service" tag
locals {
  docker_compliance_common_tags = {
    category = "Compliance"
    plugin   = "docker"
    service  = "Docker"
  }
}

variable "control_types" {
  type        = list(string)
  description = "Set of two values used to initiate the execution of compliance controls using only specific plugin or both"
  # A list of plugin names to include as execution mode for macOS or Linux based OS
  # Default setting is using both docker & exec
  default = ["docker", "exec"]
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

mod "docker_compliance" {
  # hub metadata
  title         = "Docker Compliance"
  description   = "Run individual configuration, compliance and security controls or full compliance benchmarks for CIS controls across all your Docker resources using Steampipe."
  color         = "#0db7ed"
  documentation = file("./docs/index.md")
  icon          = "/images/mods/turbot/docker-compliance.svg"
  categories    = ["docker", "cis", "compliance"]

  opengraph {
    title       = "Steampipe Mod for Docker Compliance"
    description = "Run individual configuration, compliance and security controls or full compliance benchmarks for CIS controls across all your Docker resources using Steampipe."
    image       = "/images/mods/turbot/docker-compliance-social-graphic.png"
  }

  /*
  require {
    plugin "docker" {
      version = "0.9.0"
    }
    plugin "exec" {
      version = "0.0.4"
    }
  }
  */
}
