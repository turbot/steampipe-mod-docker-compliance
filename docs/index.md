---
repository: "https://github.com/turbot/steampipe-mod-docker-compliance"
---

# Docker Compliance Mod

Run individual configuration, compliance and security controls or full compliance benchmarks for `CIS` across all your Docker resources.

<img src="https://raw.githubusercontent.com/turbot/steampipe-mod-docker-compliance/main/docs/docker_compliance_dashboard.png" width="50%" type="thumbnail"/>
<img src="https://raw.githubusercontent.com/turbot/steampipe-mod-docker-compliance/main/docs/docker_cis_v160_dashboard.png" width="50%" type="thumbnail"/>
<img src="https://raw.githubusercontent.com/turbot/steampipe-mod-docker-compliance/main/docs/docker_cis_v160_console.png" width="50%" type="thumbnail"/>

## References

[CIS Docker Benchmarks](https://www.cisecurity.org) provide a predefined set of compliance and security best-practice checks for Docker resources.

[Steampipe](https://steampipe.io) is an open source CLI to instantly query cloud APIs using SQL.

[Steampipe Mods](https://steampipe.io/docs/reference/mod-resources#mod) are collections of `named queries`, and codified `controls` that can be used to test current configuration of your cloud resources against a desired configuration.

## Documentation

- **[Benchmarks and controls →](https://hub.steampipe.io/mods/turbot/docker_compliance/controls)**
- **[Named queries →](https://hub.steampipe.io/mods/turbot/docker_compliance/queries)**

## Installation

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

## Usage

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
steampipe check benchmark.cis_v160 --workspace docker_exec_local
steampipe check benchmark.cis_v160 --workspace docker_exec_remote
```

Additional argments can be set in each workspace, including cache TTL, mod location, and more. Please see [Workspace Arguments](https://steampipe.io/docs/reference/config-files/workspace#workspace-arguments) for a full list.

## Setting control types

The Docker Compliance mod queries use the Docker and Exec plugin tables in order to retrieve information about the Docker Engine and the host it runs on. If you do not have access to connect to either of those, you can set the `benchmark_plugins` variable to decide which controls are included in benchmarks.

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
