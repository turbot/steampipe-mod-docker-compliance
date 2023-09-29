# Docker Compliance Mod for Steampipe

34+ checks covering industry defined security best practices for Docker. Includes full support for `CIS v1.6.0` compliance benchmarks across all your Docker resources.

**Includes full support for the CIS v1.6 Docker Benchmarks**.

Run checks in a dashboard:
![image](https://raw.githubusercontent.com/turbot/steampipe-mod-docker-compliance/main/docs/docker_cis_v160_dashboard.png)

Or in a terminal:
![image](https://raw.githubusercontent.com/turbot/steampipe-mod-docker-compliance/main/docs/docker_cis_v160_console.png)

Includes support for:

- [Docker CIS v1.6.0](https://hub.steampipe.io/mods/turbot/docker_compliance/controls/benchmark.cis_v160)

## Getting started

### Installation

Download and install Steampipe (https://steampipe.io/downloads). Or use Brew:

```sh
brew tap turbot/tap
brew install steampipe
```

Install the Docker and Exec plugins with [Steampipe](https://steampipe.io):

```sh
steampipe plugin install docker exec
```

Clone:

```sh
git clone https://github.com/turbot/steampipe-mod-docker-compliance.git
```

### Usage

Start your dashboard server to get started:

```sh
steampipe dashboard
```

By default, the dashboard interface will then be launched in a new browser
window at http://localhost:9194. From here, you can run benchmarks by
selecting one or searching for a specific one.

Instead of running benchmarks in a dashboard, you can also run them within your
terminal with the `steampipe check` command:

Run all benchmarks:

```sh
steampipe check all
```

Run a single benchmark:

```sh
steampipe check benchmark.cis_v160_5
```

Run a specific control:

```sh
steampipe check control.cis_v160_5_1
```

Different output formats are also available, for more information please see
[Output Formats](https://steampipe.io/docs/reference/cli/check#output-formats).

### Credentials

This mod uses the credentials configured in the [Steampipe Docker plugin](https://hub.steampipe.io/plugins/turbot/docker) and the [Steampipe Exec plugin](https://hub.steampipe.io/plugins/turbot/exec).

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

## Contributing

If you have an idea for additional compliance controls, or just want to help maintain and extend this mod ([or others](https://github.com/topics/steampipe-mod)) we would love you to join the community and start contributing. (Even if you just want to help with the docs.)

- **[Join #steampipe on Slack →](https://turbot.com/community/join)** and hang out with other Mod developers.

Please see the [contribution guidelines](https://github.com/turbot/steampipe/blob/main/CONTRIBUTING.md) and our [code of conduct](https://github.com/turbot/steampipe/blob/main/CODE_OF_CONDUCT.md). All contributions are subject to the [Apache 2.0 open source license](https://github.com/turbot/steampipe-mod-docker-compliance/blob/main/LICENSE).

Want to help but not sure where to start? Pick up one of the `help wanted` issues:

- [Steampipe](https://github.com/turbot/steampipe/labels/help%20wanted)
- [Docker Compliance Mod](https://github.com/turbot/steampipe-mod-docker-compliance/labels/help%20wanted)
