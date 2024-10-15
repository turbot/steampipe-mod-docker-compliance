# Docker Compliance Mod for Powerpipe

34+ checks covering industry defined security best practices for Docker. Includes full support for `CIS v1.6.0` compliance benchmarks across all your Docker resources.

**Includes full support for the CIS v1.6 Docker Benchmarks**.

Run checks in a dashboard:
![image](https://raw.githubusercontent.com/turbot/steampipe-mod-docker-compliance/main/docs/docker_cis_v160_dashboard.png)

Or in a terminal:
![image](https://raw.githubusercontent.com/turbot/steampipe-mod-docker-compliance/main/docs/docker_cis_v160_console.png)

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
steampipe plugin install docker
steampipe plugin install exec
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

Browse and view your dashboards at **http://localhost:9033**.

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

## Configuration

This mod uses the credentials configured in the [Steampipe Docker plugin](https://hub.steampipe.io/plugins/turbot/docker) and the [Steampipe Exec plugin](https://hub.steampipe.io/plugins/turbot/exec). Please see below for examples on how to configure connections for these plugins.

### Local connections

When connecting to Docker on your local host, the Docker and Exec plugin connections require basic configuration:

```hcl
connection "docker_local" {
  plugin  = "docker"
}

connection "exec_local" {
  plugin  = "exec"
}
```

### Remote connections

#### Docker without TLS enabled

Note: It is not recommended to allow insecure connections. Please see [Protect the Docker daemon socket](https://docs.docker.com/engine/security/protect-access/#use-tls-https-to-protect-the-docker-daemon-socket) for instructions on setting up TLS.

You only need to specify the `host`:

```hcl
connection "docker_remote" {
  plugin = "docker"
  host   = "tcp://12.345.67.890:2375"
}
```

To connect to the remote host, you need to provide additional details in the Exec plugin connection, including the private key:

```hcl
connection "exec_remote" {
  plugin      = "exec"
  host        = "12.345.67.890"
  user        = "ec2-user"
  protocol    = "ssh"
  private_key = "/Users/myuser/keys/key.pem"
}
```

#### Docker with TLS enabled

If Docker does have TLS enabled, you will need to set `tls_verify` and provide a path to the directory containing your certificates and key files:

```hcl
connection "docker_remote_tls" {
  plugin     = "docker"
  host       = "tcp://12.345.67.890:2376"
  tls_verify = true
  cert_path  = "/Users/myuser/certs"
}
```

The Exec plugin connection does not require any different configuration:

```hcl
connection "exec_remote" {
  plugin      = "exec"
  host        = "12.345.67.890"
  user        = "ec2-user"
  protocol    = "ssh"
  private_key = "/Users/myuser/keys/key.pem"
}
```

### Using workspaces with multiple connections

If you have multiple local and/or remote Docker and Exec connections, you can use [Steampipe workspaces](https://steampipe.io/docs/reference/config-files/workspace) to manage your Steampipe environments. Workspaces are profiles that are usually defined in `~/.steampipe/config/workspaces.spc`.

For instance, if multiple Docker and Exec plugin connections were configured:

```hcl
connection "docker_local" {
  plugin  = "docker"
}

connection "docker_remote_tls" {
  plugin     = "docker"
  host       = "tcp://12.345.67.890:2376"
  tls_verify = true
  cert_path  = "/Users/myuser/certs"
}
```

```hcl
connection "exec_local" {
  plugin  = "exec"
}

connection "exec_remote" {
  plugin      = "exec"
  host        = "12.345.67.890"
  user        = "ec2-user"
  protocol    = "ssh"
  private_key = "/Users/myuser/keys/key.pem"
}
```

You can create multiple workspaces in `~/.steampipe/config/workspaces.spc`:

```hcl
workspace "docker_exec_local" {
  search_path_prefix = "docker_local,exec_local"
}

workspace "docker_exec_remote" {
  search_path_prefix = "docker_remote_tls,exec_remote"
}
```

To switch between workspaces, you can use the `--workspace` argument:

```sh
powerpipe benchmark run cis_v160 --workspace docker_exec_local
powerpipe benchmark run cis_v160 --workspace docker_exec_remote
```

Additional argments can be set in each workspace, including cache TTL, mod location, and more. Please see [Workspace Arguments](https://steampipe.io/docs/reference/config-files/workspace#workspace-arguments) for a full list.

## Setting control types

The Docker Compliance mod queries use the Docker and Exec plugin tables in order to retrieve information about the Docker Engine and the host it runs on. If you do not have access to connect to either of those, you can set the `benchmark_plugins` variable to decide which controls are included in benchmarks.

By default, both Docker and Exec queries are included:

```hcl
benchmark_plugins = ["docker", "exec"]
```

To only execute queries using Docker plugin tables, create `steampipe.ppvars` with the following value:

```hcl
benchmark_plugins = ["docker"]
```

Note that controls can always be run directly, even if `benchmark_plugins` does not include the plugin type. For instance:

```hcl
powerpipe control run cis_v160_5
```

This variable can be overwritten in several ways:

- Copy and rename the `steampipe.ppvars.example` file to `steampipe.ppvars`, and then modify the variable values inside that file
- Pass in a value on the command line:

  ```sh
  powerpipe benchmark run cis_v160 --var 'benchmark_plugins=["docker"]'
  ```
- Set an environment variable:

  ```sh
  SP_VAR_benchmark_plugins='["exec"]' powerpipe benchmark run cis_v160
  ```

## Open Source & Contributing

This repository is published under the [Apache 2.0 license](https://www.apache.org/licenses/LICENSE-2.0). Please see our [code of conduct](https://github.com/turbot/.github/blob/main/CODE_OF_CONDUCT.md). We look forward to collaborating with you!

[Steampipe](https://steampipe.io) and [Powerpipe](https://powerpipe.io) are products produced from this open source software, exclusively by [Turbot HQ, Inc](https://turbot.com). They are distributed under our commercial terms. Others are allowed to make their own distribution of the software, but cannot use any of the Turbot trademarks, cloud services, etc. You can learn more in our [Open Source FAQ](https://turbot.com/open-source).

## Get Involved

**[Join #powerpipe on Slack →](https://turbot.com/community/join)**

Want to help but don't know where to start? Pick up one of the `help wanted` issues:

- [Powerpipe](https://github.com/turbot/powerpipe/labels/help%20wanted)
- [Docker Compliance Mod](https://github.com/turbot/steampipe-mod-docker-compliance/labels/help%20wanted)
