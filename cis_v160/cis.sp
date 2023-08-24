locals {
  cis_v160_common_tags = merge(local.docker_compliance_common_tags, {
    cis         = "true"
    cis_version = "v1.6.0"
  })
}

benchmark "cis_v160" {
  title         = "CIS v1.6.0"
  description   = "The CIS Docker Benchmark provides prescriptive guidance for establishing a secure configuration posture for Docker Engine v20.10. This guide was tested against Docker Engine 20.10.20 on RHEL 7 and Ubuntu 20.04."
  documentation = file("./cis_v160/docs/cis_v160_overview.md")
  children = [
    benchmark.cis_v160_1,
    benchmark.cis_v160_2,
    benchmark.cis_v160_4,
    benchmark.cis_v160_5,
    benchmark.cis_v160_6,
    benchmark.cis_v160_7
  ]

  tags = merge(local.cis_v160_common_tags, {
    type = "Benchmark"
  })
}
