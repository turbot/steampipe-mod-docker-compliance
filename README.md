# Docker Compliance Mod for Powerpipe

> [!IMPORTANT]  
> Steampipe mods are [migrating to Powerpipe format](https://powerpipe.io) to gain new features. This mod currently works with both Steampipe and Powerpipe, but will only support Powerpipe from v1.x onward.

34+ checks covering industry defined security best practices for Docker. Includes full support for `CIS v1.6.0` compliance benchmarks across all your Docker resources.

**Includes full support for the CIS v1.6 Docker Benchmarks**.

Run checks in a dashboard:
<!-- ![image](https://raw.githubusercontent.com/turbot/steampipe-mod-docker-compliance/main/docs/docker_cis_v160_dashboard.png) -->
![image](https://raw.githubusercontent.com/turbot/steampipe-mod-docker-compliance/add-new-checks/docs/docker_cis_v160_dashboard.png)

Or in a terminal:
<!-- ![image](https://raw.githubusercontent.com/turbot/steampipe-mod-docker-compliance/main/docs/docker_cis_v160_console.png) -->
![image](https://raw.githubusercontent.com/turbot/steampipe-mod-docker-compliance/add-new-checks/docs/docker_cis_v160_console.png)

Includes support for:

- [Docker CIS v1.6.0](https://hub.steampipe.io/mods/turbot/docker_compliance/controls/benchmark.cis_v160)

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
powerpipe mod install github.com/turbot/steampipe-mod-docker-compliance
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

### Configuration

The Docker Compliance mod queries use the Docker and Exec plugin tables in order to retrieve information about the Docker Engine and the host it runs on. If you do not have access to connect to either of those, you can set the `benchmark_plugins` variable to decide which controls to include.

By default, both Docker and Exec queries are included:

```hcl
benchmark_plugins = ["docker", "exec"]
```

To only execute queries using Docker plugin tables, create `steampipe.spvars` with the following value:

```hcl
benchmark_plugins = ["docker"]
```

Note that controls can always be run directly, even if `benchmark_plugins` does not include the plugin type. For instance:

```hcl
steampipe check control.cis_v160_5
```

This variable can be overwritten in several ways:

- Copy and rename the `steampipe.spvars.example` file to `steampipe.spvars`, and then modify the variable values inside that file
- Pass in a value on the command line:

  ```sh
  steampipe check benchmark.cis_v160 --var 'benchmark_plugins=["docker"]'
  ```
- Set an environment variable:

  ```sh
  SP_VAR_benchmark_plugins='["exec"]' steampipe check benchmark.cis_v160
  ```

## Open Source & Contributing

This repository is published under the [Apache 2.0 license](https://www.apache.org/licenses/LICENSE-2.0). Please see our [code of conduct](https://github.com/turbot/.github/blob/main/CODE_OF_CONDUCT.md). We look forward to collaborating with you!

[Steampipe](https://steampipe.io) and [Powerpipe](https://powerpipe.io) are products produced from this open source software, exclusively by [Turbot HQ, Inc](https://turbot.com). They are distributed under our commercial terms. Others are allowed to make their own distribution of the software, but cannot use any of the Turbot trademarks, cloud services, etc. You can learn more in our [Open Source FAQ](https://turbot.com/open-source).

## Get Involved

**[Join #powerpipe on Slack →](https://turbot.com/community/join)**

Want to help but don't know where to start? Pick up one of the `help wanted` issues:

- [Powerpipe](https://github.com/turbot/powerpipe/labels/help%20wanted)
- [Docker Compliance Mod](https://github.com/turbot/steampipe-mod-docker-compliance/labels/help%20wanted)
