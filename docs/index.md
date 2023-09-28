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

## Docker & Exec configuration

### Local configuration

Docker is hosted in local macOS or Linux operating system, you can keep the default configuration in respective config files.

```
connection "docker" {
  plugin  = "docker"
}
```

```
connection "exec" {
  plugin  = "exec"
}
```

### Remote configuration with encryption

Docker is hosted in remote operating system e.g. Linux, and user is initiating connection from local macOS
More [info](https://docs.docker.com/engine/security/protect-access/#use-tls-https-to-protect-the-docker-daemon-socket) to protect the Docker daemon

`docker.spc`
```
connection "docker" {
  plugin = "docker"
  host        = "tcp://12.345.67.890:2376"
  cert_path   = "<path to the cert and key files>"
  api_version = "1.41"
  tls_verify  = true
}
```

**Note:**

- Docker over TLS should run on TCP port 2376.
- *api_version* is the Docker API version used on the remote server. You can check this by `docker version` command*

`exec.spc`
```
connection "exec" {
  plugin      = "exec"
  host        = "12.345.67.890"
  user        = "ec2-user"
  protocol    = "ssh"
  private_key = "<path to the server private key.pem file>"
}
```

### Remote configuration without encryption

`docker.spc`
```
connection "docker" {
  plugin = "docker"
  host   = "tcp://12.345.67.890:2375"
}
```
WARNING: If docker configured unencrypted, API is accessible on http://0.0.0.0:2375 without encryption. Access to the remote API is equivalent to root access on the host. Refer to the `Docker daemon attack surface section` in the documentation for more [information](https://docs.docker.com/go/attack-surface/)

`exec.spc`
```
connection "exec" {
  plugin      = "exec"
  host        = "12.345.67.890"
  user        = "ec2-user"
  protocol    = "ssh"
  private_key = "<path to the server private key.pem file>"
}
```

### Using workspace

You can leverage [workspace](https://steampipe.io/docs/reference/config-files/workspace#workspace) feature of Steampipe to control the Docker compliance execution. You choose to group respective connection info and execute benchmark or controls with [Workspace Arguments](https://steampipe.io/docs/reference/config-files/workspace#workspace-arguments). Simple example `workspace.spc` provided as below

```
# The following connection mentioned in `search_path_prefix` must be available in respective config files i.e. docker.spc & exec.spc

# Running Docker compliance in local OS
workspace "docker_cis_local" {
  search_path_prefix = "exec_local,docker_local"
}

# Running Docker compliance in local OS with remote connection
workspace "docker_cis_remote" {
  search_path_prefix = "exec_remote,docker_remote"
}
```

**Executing using workspace**

Run all benchmarks:

```sh
steampipe check all --workspace docker_cis_remote
```

Run a single benchmark:

```sh
steampipe check benchmark.cis_v160_5 --workspace docker_cis_remote
```

Run a specific control:

```sh
steampipe check control.cis_v160_5_1 --workspace docker_cis_remote
```

### Variables

 Docker compliance is not limited to validating its core components such as container, image, network, etc.; it also validates its installed & used filesystem with permissions & ownerships. Steampipe provides integration of the `Exec` plugin to evaluate such controls.

Steampipe provides a variable feature in `mod.sp` to allow the user to change the value for any specific plugin use. You can update the value to only docker if you want to execute only Docker-related controls. The default value is set to both.

```
variable "control_types" {
  type        = list(string)
  description = "Set of two values used to initiate the execution of compliance controls using only specific plugin or both"
  # A list of plugin names to include as execution mode for macOS or Linux based OS
  # Default setting is using both docker & exec
  default = ["docker", "exec"]
}
```

### Operating system compatibility

 File paths in Docker can differ between macOS and Linux due to the underlying architecture and file system differences between the two operating systems. There are some key differences in `Filesystem & path` , `Volume mounting` , `Permissions` , `Case sensitivity` etc. Due to some of these differences, some of the controls are skipped when executed in local macOS.

## Getting started

### Installation

Download and install Steampipe (https://steampipe.io/downloads). Or use Brew:

```sh
brew tap turbot/tap
brew install steampipe
```

Install the Docker & Exec plugins with [Steampipe](https://steampipe.io):

```sh
steampipe plugin install docker
steampipe plugin install exec
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

This mod uses the credentials configured in the [Steampipe Docker plugin](https://hub.steampipe.io/plugins/turbot/docker).

### Configuration

No extra configuration is required.

## Contributing

If you have an idea for additional compliance controls, or just want to help maintain and extend this mod ([or others](https://github.com/topics/steampipe-mod)) we would love you to join the community and start contributing. (Even if you just want to help with the docs.)

- **[Join #steampipe on Slack →](https://turbot.com/community/join)** and hang out with other Mod developers.

Please see the [contribution guidelines](https://github.com/turbot/steampipe/blob/main/CONTRIBUTING.md) and our [code of conduct](https://github.com/turbot/steampipe/blob/main/CODE_OF_CONDUCT.md). All contributions are subject to the [Apache 2.0 open source license](https://github.com/turbot/steampipe-mod-docker-compliance/blob/main/LICENSE).

Want to help but not sure where to start? Pick up one of the `help wanted` issues:

- [Steampipe](https://github.com/turbot/steampipe/labels/help%20wanted)
- [Docker Compliance Mod](https://github.com/turbot/steampipe-mod-docker-compliance/labels/help%20wanted)
