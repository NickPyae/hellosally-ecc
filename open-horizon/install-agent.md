# Install the Open Horizon Agent

Provision a new VM to run the Horizon Agent (Anax). Do not attempt this in the same environment or VM as the Horizon Services 
due to port conflicts and environment variable collisions.

Become root so the following several steps will work properly

``` bash
sudo -s
```

Update the package manager

``` bash
apt-get -y update
```

Install dependencies

``` bash
apt-get -y install jq
```

Install and test Docker

``` bash
curl -fsSL get.docker.com | sh
docker --version
```

Install the Anax Agent and CLI:

Note: We are going to download horizon cli and agent package from open-horizon anax repo releases.

``` bash
wget https://github.com/open-horizon/anax/releases/download/v2.28.0-338/horizon-agent-linux-deb-amd64.tar.gz
tar -xzvf horizon-agent-linux-deb-amd64.tar.gz
dpkg -i horizon-cli_2.28.0-338_amd64.deb
dpkg -i horizon_2.28.0-338_amd64.deb
```

Check the version to confirm that the Horizon CLI is installed and working

``` bash
hzn version
```

Check to ensure that it is working and your machine/node is "unconfigured"

``` bash
hzn node list
```
When you look at the output for `hzn node list`, pay attention to the line for the exchange api:

``` json
"exchange_api": ""
```

When the Agent is properly configured, 
it will point to the public IP address of the Horizon Management Hub Services that you stood up earlier, and is useful for confirming proper configuration.

To fix this, you will edit the horizon agent configuration file and then restart the agent service.

Please note two important details: first, the protocol is `http` instead of `https` (due to lack of a public signed cert), 
and second, the URL *must* end with a trailing slash, even though the corresponding environment variable does not.  

NOTE: Replace `x.x.x.x` with the actual IP address of the machine running the Open Horizon Hub Services.

Edit the file at `/etc/default/horizon` using `sudo` to set the exchange URL (HZN_EXCHANGE_URL) to `http://x.x.x.x:3090/v1/`.

Also add the MSS URL and set your device id.

Edit the file at `/etc/default/horizon` using `sudo` to set the MMS URL (HZN_FSS_CSSURL) to `http://x.x.x.x:9443`.
Edit the file at `/etc/default/horizon` using `sudo` to set the device id (HZN_DEVICE_ID) to whatever you want, e.g. mynode.

``` bash
nano /etc/default/horizon

HZN_EXCHANGE_URL=http://x.x.x.x:3090/v1/
HZN_FSS_CSSURL=http://x.x.x.x:9443
HZN_MGMT_HUB_CERT_PATH=
HZN_DEVICE_ID=
HZN_AGENT_PORT=8510
```
Restart the Agent service:

``` bash
sudo systemctl restart horizon
```

and confirm that the changes took effect by re-running `hzn node list` and checking the `exchange_api` value.

Also, verify that the "exchange_version" is correct.
If it is an empty string, then the agent does not have network connectivity to the exchange.
You will need to resolve this problem before you continue.

Configure environment variables so the Open Horizon hzn CLI can connect to the exchange from Agent VM.

NOTE: Replace `x.x.x.x` with the actual IP address of the machine running the Open Horizon Management Hub Services. Also, replace `YOUR_EXCHANGE_ADMIN_PASSWORD` with the same password you exported in [Build and Run Open Horizon Management Hub Services](https://eos2git.cec.lab.emc.com/ISG-Edge/hellosally-ecc/blob/main/open-horizon/build-and-run-horizon.md#create-and-persist-environment-variables)

``` bash
echo "export HZN_EXCHANGE_URL=http://x.x.x.x:3090/v1" >> ~/.bashrc
echo "export ORG_ID=dellsg" >> ~/.bashrc
echo "export HZN_ORG_ID=dellsg" >> ~/.bashrc
echo "export HZN_EXCHANGE_USER_AUTH=admin:YOUR_EXCHANGE_ADMIN_PASSWORD" >> ~/.bashrc
source ~/.bashrc

hzn exchange user list
```

The results of `hzn exchange user list` should be something like the following:

``` json
{
  "dellsg/admin": {
    "admin": true,
    "email": "admin@dellsg",
    "lastUpdated": "2019-08-19T12:25:06.754Z[UTC]",
    "password": "********",
    "updatedBy": "root/root"
  }
}
```

### Log into Container Registry
This step is only required if you are pulling images from private JFrog Artifactory. For development and testing of Open Horizon on VirtualBox, this step is not needed.

``` bash
docker login amaas-eos-mw1.cec.lab.emc.com:5070
```

Once it asks for user name and password, use your service account user name and API Key as password from JFrog Artifactory.

# Next

[Deploy Open Horizon (ECE) Services](./app-definition/README.md).
