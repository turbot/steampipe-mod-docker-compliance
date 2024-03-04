---
repository: "https://github.com/turbot/steampipe-mod-docker-compliance"
---

# Docker Compliance Mod

Run individual configuration, compliance and security controls or full compliance benchmarks for `CIS` across all your Docker resources.

<!-- <img src="https://raw.githubusercontent.com/turbot/steampipe-mod-docker-compliance/main/docs/docker_compliance_dashboard.png" width="50%" type="thumbnail"/>
<img src="https://raw.githubusercontent.com/turbot/steampipe-mod-docker-compliance/main/docs/docker_cis_v160_dashboard.png" width="50%" type="thumbnail"/>
<img src="https://raw.githubusercontent.com/turbot/steampipe-mod-docker-compliance/main/docs/docker_cis_v160_console.png" width="50%" type="thumbnail"/> -->
<img src="https://raw.githubusercontent.com/turbot/steampipe-mod-docker-compliance/add-new-checks/docs/docker_compliance_dashboard.png" width="50%" type="thumbnail"/>
<img src="https://raw.githubusercontent.com/turbot/steampipe-mod-docker-compliance/add-new-checks/docs/docker_cis_v160_dashboard.png" width="50%" type="thumbnail"/>
<img src="https://raw.githubusercontent.com/turbot/steampipe-mod-docker-compliance/add-new-checks/docs/docker_cis_v160_console.png" width="50%" type="thumbnail"/>

## References

[CIS Docker Benchmarks](https://www.cisecurity.org) provide a predefined set of compliance and security best-practice checks for Docker resources.

[Steampipe](https://steampipe.io) is an open source CLI to instantly query cloud APIs using SQL.

[Steampipe Mods](https://steampipe.io/docs/reference/mod-resources#mod) are collections of `named queries`, and codified `controls` that can be used to test current configuration of your cloud resources against a desired configuration.

## Documentation

- **[Benchmarks and controls →](https://hub.powerpipe.io/mods/turbot/docker_compliance/controls)**
- **[Named queries →](https://hub.powerpipe.io/mods/turbot/docker_compliance/queries)**

## Getting Started

### Installation

Install Powerpipe (https://powerpipe.io/downloads), or use Brew:

```sh
brew install turbot/tap/powerpipe
```

This mod also requires [Steampipe](https://steampipe.io) with the [Docker plugin](https://hub.steampipe.io/plugins/turbot/docker) and the [Exec plugin](https://hub.steampipe.io/plugins/turbot/exec) as the data source. Install Steampipe (https://steampipe.io/downloads), or use Brew:

Install the Docker and Exec plugins with [Steampipe](https://steampipe.io):

```sh
brew install turbot/tap/steampipe
steampipe plugin install docker exec
```

Steampipe will automatically use your default Docker credentials.

Finally, install the mod:

```sh
mkdir dashboards
cd dashboards
powerpipe mod init
powerpipe mod install github.com/turbot/powerpipe-mod-docker-compliance
```

### Browsing Dashboards

Start Steampipe as the data source:

```sh
steampipe service start
```

Start the dashboard server:

```sh
powerpipe server
```

Browse and view your dashboards at **https://localhost:9033**.

### Running Checks in Your Terminal

Instead of running benchmarks in a dashboard, you can also run them within your
terminal with the `powerpipe benchmark` command:

List available benchmarks:

```sh
powerpipe benchmark list
```

Run a benchmark:

```sh
powerpipe benchmark run docker_compliance.benchmark.cis_v160_5
```

Different output formats are also available, for more information please see
[Output Formats](https://powerpipe.io/docs/reference/cli/benchmark#output-formats).

## Open Source & Contributing

This repository is published under the [Apache 2.0 license](https://www.apache.org/licenses/LICENSE-2.0). Please see our [code of conduct](https://github.com/turbot/.github/blob/main/CODE_OF_CONDUCT.md). We look forward to collaborating with you!

[Steampipe](https://steampipe.io) and [Powerpipe](https://powerpipe.io) are products produced from this open source software, exclusively by [Turbot HQ, Inc](https://turbot.com). They are distributed under our commercial terms. Others are allowed to make their own distribution of the software, but cannot use any of the Turbot trademarks, cloud services, etc. You can learn more in our [Open Source FAQ](https://turbot.com/open-source).

## Get Involved

**[Join #powerpipe on Slack →](https://turbot.com/community/join)**

Want to help but don't know where to start? Pick up one of the `help wanted` issues:

- [Powerpipe](https://github.com/turbot/powerpipe/labels/help%20wanted)
- [AWS Compliance Mod](https://github.com/turbot/steampipe-mod-aws-compliance/labels/help%20wanted)
