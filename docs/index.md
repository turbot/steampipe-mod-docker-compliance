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

When docker is hosted in local macOS or Linux operating system

```
connection "docker" {
  plugin = "docker"
}
```

```
connection "exec" {
  plugin      = "exec"
}
```

### Remote configuration

When docker is hosted in remote operating system

```
connection "docker" {
  plugin = "docker"
  host        = "tcp://12.345.67.890:2376"
  cert_path   = "<path to the cert and key files>"
  api_version = "1.41"
  tls_verify  = true
}
```
***api_version** is the Docker API version used on the remote server. You can check this by `docker version` command*
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

// TO DO

### Multiple connection

// TO DO

### Variables

// TO DO

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
