# Prerequisites

1 VM to run Open Horizon Management Hub Services and another VM to run Open Horizon Agent (Anax) which will also run containerized workload or services

### Open Horizon Management Hub Services (Exchange, Switchboard, AgBots, Sync Service)
+ OS: Ubuntu server, latest build recommended.  Instructions assume this.
+ VM: 4Gb RAM, 20Gb storage, 1vCPU, root access

### Open Horizon Agent (Anax)
+ OS: Ubuntu server or desktop (latest build recommended).  
+ VM: 1Gb RAM, 10Gb storage, 1vCPU, root access

## Initial setup

Provision a new VM to run Horizon Management Hub Services.
*NOTE*: You will need to perform all of these tasks as root.


``` bash
git clone https://eos2git.cec.lab.emc.com/ISG-Edge/hellosally-ecc.git
```

### Install Prerequisites

NOTE: If you are not already running as root, please become root with `sudo -s` or similar.

``` bash
apt-get -y update
apt-get -y install apache2-utils jq curl make gcc
```

### Install Container Engine

``` bash
curl -fsSL get.docker.com | sh
curl -L "https://github.com/docker/compose/releases/download/1.29.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
```

### Log into Container Registry
This step is only required if you are pulling images from private JFrog Artifactory. For development and testing of Open Horizon on VirtualBox, this step is not needed.

``` bash
docker login amaas-eos-mw1.cec.lab.emc.com:5070
```

Once it asks for user name and password, use your service account user name and API Key as password from JFrog Artifactory.

## Next

[Build and Run](build-and-run-horizon.md) the Open Horizon Management Hub Services.
