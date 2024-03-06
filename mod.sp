mod "docker_compliance" {
  # Hub metadata
  title         = "Docker Compliance"
  description   = "Run individual configuration, compliance and security controls or full compliance benchmarks for CIS controls across all your Docker resources using Powerpipe and Steampipe."
  color         = "#0db7ed"
  documentation = file("./docs/index.md")
  icon          = "/images/mods/turbot/docker-compliance.svg"
  categories    = ["docker", "cis", "compliance", "iac"]

  opengraph {
    title       = "Powerpipe Mod for Docker Compliance"
    description = "Run individual configuration, compliance and security controls or full compliance benchmarks for CIS controls across all your Docker resources using Powerpipe and Steampipe."
    image       = "/images/mods/turbot/docker-compliance-social-graphic.png"
  }

  require {
    plugin "docker" {
      min_version = "0.9.0"
    }
    plugin "exec" {
      min_version = "0.0.4"
    }
  }
}
