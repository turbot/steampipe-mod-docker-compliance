// Benchmarks and controls for specific services should override the "service" tag
locals {
  docker_compliance_common_tags = {
    category = "Compliance"
    plugin   = "docker"
    service  = "Docker"
  }
}

variable "plugin" {
  type        = list(string)
  description = "TO-DO"
  default = ["docker", "exec"]
}

mod "docker_compliance" {
  # hub metadata
  title         = "Docker Compliance"
  description   = "Run individual configuration, compliance and security controls or full compliance benchmarks for CIS controls across all your Docker resources using Steampipe."
  color         = "#FF9900"
  documentation = file("./docs/index.md")
  icon          = "/images/mods/turbot/docker-compliance.svg"
  categories    = ["docker", "cis", "compliance"]

  opengraph {
    title       = "Steampipe Mod for Docker Compliance"
    description = "Run individual configuration, compliance and security controls or full compliance benchmarks for CIS controls across all your Docker resources using Steampipe."
    image       = "/images/mods/turbot/docker-compliance-social-graphic.png"
  }

  require {
    plugin "docker" {
      version = "0.7.0"
    }
    plugin "exec" {
      version = "0.0.1"
    }
  }
}
