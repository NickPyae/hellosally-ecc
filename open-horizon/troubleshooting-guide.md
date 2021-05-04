# How to troubleshoot

## iptables rule reset after reboot

``` bash
iptables -t nat -I PREROUTING -p tcp -d agent_vm_ip/24 --dport 8510 -j DNAT --to-destination 127.0.0.1:8510
sysctl -w net.ipv4.conf.enp0s8.route_localnet=1
```

This iptables rule you set on your Agent VM is not permanent. Once you have restarted your machine, your iptables rule will be gone.
To fix this,

``` bash
apt-get install iptables-persistent
nano /etc/sysctl.conf
```
Paste this: `net.ipv4.conf.enp0s8.route_localnet=1` . Make sure you replace `enp0s8` with correct network adapter that Agent VM IP resides and `agent_vm_ip` with correct Agent VM IP.

## hzn node list, hzn register does not work anymore when exeucted from Management Hub VM

1. Make sure you check your iptables rule in your agent VM and it's properly set in the first place.
2. Make sure you export your `HORIZON_URL` on your management VM with correct Agent VM IP. 
For example, `export HORIZON_URL=http://x.x.x.x:8510`


### Check which API hzn CLI is calling

You can pass `-v` flag to check which API hzn CLI is calling under the hood.

``` bash
hzn node list -v
```

## No agreement list after deployment 

After you deploy your services either using pattern or policies, you run `hzn agreement list` to check the agreement between your agent and management hub. Agreement should be reached after 1 to 2 mins max. You should see something similar to this 

``` bash
{
    "name": "Policy for dellsg/86ff099fb02549be4518518e650d8d3bdc6888a9 merged with dellsg/hellosally",
    "current_agreement_id": "1e49ce3f1f1c156134c8eac8c74445bb8c2a78648d9f7b392deaefe0491dd463",
    "consumer_id": "dellsg/agbot1",
    "agreement_creation_time": "2021-04-26 13:06:15 +0000 UTC",
    "agreement_accepted_time": "2021-04-26 13:06:26 +0000 UTC",
    "agreement_finalized_time": "2021-04-26 13:06:26 +0000 UTC",
    "agreement_execution_start_time": "",
    "agreement_data_received_time": "",
    "agreement_protocol": "Basic",
    "workload_to_run": {
      "url": "com.eos2git.cec.lab.emc.hellosally",
      "org": "dellsg",
      "version": "0.0.1",
      "arch": "amd64"
    }
  }

```

If you see empty `[]` instead of above payload even after waiting for a few mins, what you should do is you should restart 
`openhorizon/amd64_exchange-api` and `openhorizon/amd64_agbot` containers from management hub.


``` bash
docker restart CONTAINER_ID
```

Once you have done this, you can run `hzn unregister -D` on agent node and then `hzn register` and re-try your deployment either using pattern or policies.