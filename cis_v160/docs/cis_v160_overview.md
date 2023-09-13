To obtain the latest version of this guide, please visit http://benchmarks.cisecurity.org.

## Overview

CIS v1.6.0 benchmark provides prescriptive guidance for establishing a secure configuration posture for Docker Engine v20.10.


## Note (Draft)

The section `cis_v160_1_1_1` to `cis_v160_1_1_18` controls are evaluated using `auditctl` a command line tool compatible to Linux OS. As Mac OS does not support `auditctl`, when the related benchmark `cis_v160_1_1` is executed from Mac OS, all these controls are skipped while the query evaluates the targeted OS.

The controls are only evaluated when executed in Linux OS in following ways

- Using [Exec](https://hub.steampipe.io/plugins/turbot/exec) plugin, which allows to connect your remote docker host.
- Directly in the Linux server, where Docker is hosted. If you want to execute benchmark in the Docker server, you need to follow required installations such as
  - [Steampipe CLI](https://steampipe.io/downloads)
  - [Steampipe plugin](https://steampipe.io/downloads)
  - [Docker plugin](https://hub.steampipe.io/plugins/turbot/docker)
  - [Exec Plugin](https://hub.steampipe.io/plugins/turbot/exec)