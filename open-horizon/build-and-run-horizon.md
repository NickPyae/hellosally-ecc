# Build and Run Open Horizon Management Hub Services

### Create and Persist Environment Variables

Replace all your `YOUR_EXCHANGE_ROOT_PASSWORD` and `YOUR_EXCHANGE_ADMIN_PASSWORD` with correct values you like before exporting them.

``` bash
export EXCHANGE_PASSWORD=YOUR_EXCHANGE_ROOT_PASSWORD
export EXCHANGE_ADMIN_PASSWORD=YOUR_EXCHANGE_ADMIN_PASSWORD
export MY_IP=`ifconfig | egrep 'inet ' | sed 's/addr://' | awk '{ print $2 }' | egrep -v '^172.|^10.|^127.' | head -1`
echo "export MY_IP=${MY_IP}" >> ~/.bashrc
echo "export HZN_ORG_ID=dellsg" >> ~/.bashrc
echo "export HZN_EXCHANGE_URL=http://${MY_IP}:3090/v1/" >> ~/.bashrc
echo "export HZN_FSS_CSSURL=http://${MY_IP}:9443" >> ~/.bashrc
echo "export HZN_EXCHANGE_ROOT_USER_AUTH=root/root:YOUR_EXCHANGE_ROOT_PASSWORD" >> ~/.bashrc
echo "export HZN_EXCHANGE_USER_AUTH=admin:YOUR_EXCHANGE_ADMIN_PASSWORD" >> ~/.bashrc
source ~/.bashrc
```

### Edit Management Hub Services Configuration JSON

NOTE: Again, this is assuming that you cloned this repository and it is located at `./open-horizon/`.

Change to the `scripts` folder and and generate the hub config file, config.json.
Edit the `config.json` file if you would like to make changes.

``` bash
cd open-horizon/scripts
envsubst '${MY_IP}' < config.json.template > config.json
```

### Build and Start the Services
NOTE: The ECC-GUI is pulled in from the artifactory based docker registry and requires at this point that the user is logged in to the registry
NOTE: I am assuming that you are still in the `open-horizon/scripts` directory.

``` bash
make
make up
```

NOTE: `openhorizon/amd64_exchange-api` container will exit due to file permission. To verify this, run `docker ps -a`, you will see that this particular container exited. To fix this issue, run below command in current `open-horizon/scripts` directory

``` bash
chmod -R 777 exchange
make up
```

Install Open Horizon hzn CLI:

Note: We are going to download horizon cli from open-horizon anax repo releases.

``` bash
wget https://github.com/open-horizon/anax/releases/download/v2.28.0-338/horizon-agent-linux-deb-amd64.tar.gz
tar -xzvf horizon-agent-linux-deb-amd64.tar.gz
dpkg -i horizon-cli_2.28.0-338_amd64.deb
```

Let's confirm that the Exchange is running (and our environment variable are configured correctly) by 
requesting the endpoints for `version` and `status`:

``` bash
curl -u ${HZN_EXCHANGE_ROOT_USER_AUTH} ${HZN_EXCHANGE_URL}admin/version
```

``` bash
curl -s -u ${HZN_EXCHANGE_ROOT_USER_AUTH} ${HZN_EXCHANGE_URL}admin/status | jq .
```

If all is well, let's create `dellsg` organization and administrative user

``` bash
chmod +x prime-exchange.sh
make prime
```

If all is well, let's continue by listing the existing Organizations:

``` bash
curl -s -u ${HZN_EXCHANGE_ROOT_USER_AUTH} ${HZN_EXCHANGE_URL}orgs | jq .
```

The step you just performed created an admin user for your dellsg and also told your new AgBot `agbot1` to listen for Deployment Patterns and Policies from the `dellsg` Organization.

List the current users in `dellsg`:

``` bash
curl -sSf -u ${HZN_EXCHANGE_ROOT_USER_AUTH} ${HZN_EXCHANGE_URL}orgs/dellsg/users | jq .
```

## Next

[Install the Open Horizon Agent](install-agent.md).