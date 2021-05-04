# Exposing Open Horizon Agent API for External Access

Agent API is normally listening at `127.0.0.1:8510` and it can only be accessible within the VM that Agent is running. Therefore, you can only run these hzn CLI commands like `hzn register`, `hzn node list`, `hzn agreement list`, `hzn eventlog list` etc. from Agent node or VM since these commands are calling Agent APIs under the hood. You can verify which API these commands are calling by passing `-v` flag. If you are trying to run these commands from management hub node or VM, you will see this kind of error:

``` bash
Error: Can't connect to the Horizon REST API to run GET http://localhost:8510/node. Run 'systemctl status horizon' to check if the Horizon agent is running. Or run 'curl http://localhost:8081/status' to check the Horizon agent status. Or set HORIZON_URL to connect to another local port that is connected to a remote Horizon agent via a ssh tunnel. Specific error is: Get "http://localhost:8510/node": dial tcp 127.0.0.1:8510: connect: connection refused
```

Therefore, if you like to run these hzn CLI commands only from management hub VM, you have to follow either one of below workarounds.

On Agent VM, run

``` bash
systemctl status horizon
```

You should see Agent binary is active and running as systemd service. Agent API is currently listening at `127.0.0.1:8510`. You can check the configuration file of Agent by

``` bash
cat /etc/horizon/anax.json
```

Since this API is listening at loopback address and port 8510, this port is not accessible outside of Agent VM. 

## SSH tunnel local port forwarding from Management Hub VM to Agent VM

Before you start, make sure your ssh servers are running on both Management Hub VM and Agent VM. Replace `x.x.x.x` with the actual IP address of the machine running Agent.

On Management Hub VM, run

``` bash
ssh -f -N user_name@agent_vm_ip -L 8510:127.0.0.1:8510
export HORIZON_URL=http://x.x.x.x:8510 
```
Replace `user_name` with your Agent VM user name and `agent_vm_ip` with your Agent VM IP.
If ssh asks for user name and password, key in your ssh user name and password of Agent VM.

You can verify that your Management Hub VM can communicate to Agent API:

``` bash
hzn node list -v | jq '.configstate'
```

You should see output similar to this:

``` bash
{
  "state": "configured", // "unconfigured" if you have not registered your Agent node to Hub
  "last_update_time": "2020-04-04 07:37:39 -0700 PDT"
}
```

## iptables rule and port forwarding incoming request to Agent API

On Agent VM, run

``` bash
iptables -t nat -I PREROUTING -p tcp -d agent_vm_ip/24 --dport 8510 -j DNAT --to-destination 127.0.0.1:8510
sysctl -w net.ipv4.conf.enp0s8.route_localnet=1
```

Replace `agent_vm_ip` with your Agent VM IP. Also replace `enp0s8` with the correct network adapter name that your `agent_vm_ip` resides.

On Management Hub VM, run

``` bash
export HORIZON_URL=http://x.x.x.x:8510 
```

Replace `x.x.x.x` with the actual IP address of the machine running Agent.

You can verify that your Management Hub VM can communicate to Agent API:

``` bash
hzn node list -v | jq '.configstate'
```

You should see output similar to this:

``` bash
{
  "state": "configured", // "unconfigured" if you have not registered your Agent node to Hub
  "last_update_time": "2020-04-04 07:37:39 -0700 PDT"
}
```
