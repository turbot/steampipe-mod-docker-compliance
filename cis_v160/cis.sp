locals {
  cis_v130_common_tags = merge(local.aws_compliance_common_tags, {
    cis         = "true"
    cis_version = "v1.6.0"
  })
}

benchmark "cis_v160" {
  title         = "CIS v1.6.0"
  description   = "The CIS Amazon Web Services Foundations Benchmark provides prescriptive guidance for configuring security options for a subset of Amazon Web Services with an emphasis on foundational, testable, and architecture agnostic settings."
  documentation = file("./cis_v160/docs/cis_overview.md")
  children = [
    benchmark.cis_v160_1,
    benchmark.cis_v160_2,
    benchmark.cis_v160_3,
    benchmark.cis_v160_4,
    benchmark.cis_v160_5
  ]

  tags = merge(local.cis_v160_common_tags, {
    type = "Benchmark"
  })
}
