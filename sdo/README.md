# Open Horizon SDO

Open horizon integration with Intel SDO framework. 
1. Horizon management hub with customer service
2. Agent node with device credentials 
3. RV server

### On management hub (ECC)

Setup and Run management hub with customer service

A management hub server is bundled with the owner service docker container. Please refer to [Build and Run Open Horizon Management Hub Services](https://eos2git.cec.lab.emc.com/ISG-Edge/hellosally-ecc/blob/main/open-horizon/build-and-run-horizon.md) to set up management hub.
On make build, owner service docker will be running and listening to TO0, TO1, and TO2 protocol execution. 
Please refer to this confluence for more details about these protocol specifications. https://confluence.cec.lab.emc.com/display/ISGPDE/SDO+-+Secure+Device+Onboard

#### How to import voucher on management hub (ECC):

An ownership voucher is a file that the device manufacturer gives to the purchaser (owner) along with the physical device. 

An hzn voucher sub-command to import one or more ownership vouchers into a horizon instance

``` bash
cd /root
mkdir devices
cd devices
mkdir <DEVICE_ID> #Device UUID from agent node with simulated manufacturer device
cd <DEVICE_ID>
vi voucher.json #copy contents from ownership voucher from /var/sdo/voucher.json from agent node with simulated manufacturer device
```

Import Voucher:

``` bash
export SDO_RV_URL=http://sdo-sbx.trustedservices.intel.com:80
export HZN_SDO_SVC_URL=http://MANAGEMENT_HUB_VM_IP:9008/api
hzn voucher import voucher.json
```

Replace `MANAGEMENT_HUB_VM_IP` with correct VM IP.

### Agent Node:

Prepare agent node with simulated manufacturer device.

Setup Device: (Create voucher, install device credentials). Login to VM(device) as root and execute the below steps.

``` bash
mkdir -p $HOME/sdo && cd $HOME/sdo
curl -sSLO https://github.com/open-horizon/SDO-support/releases/download/v1.10/simulate-mfg.sh
chmod +x simulate-mfg.sh
export SDO_RV_URL=http://sdo-sbx.trustedservices.intel.com:80
export SDO_SAMPLE_MFG_KEEP_SVCS=true
./simulate-mfg.sh
```

This outputs DEVICE ID and Ownership Voucher location. Copy the contents of the ownership voucher and proceed to import the voucher in the management VM. [Please refer to How to import voucher on management hub (ECC)](#How-to-import-voucher)

The above process add owner-boot-device script in /var/sdo/bin directory and creates a service definition sdo_to in /var/sdo

Update the service definition by adding postscripts to update IP tables. This is a workaround for management control agent VM.

Add the below line in service file:

``` bash
cd /usr/sdo
vi sdo_to.service
#Add the below line after ExecStart command as a post processing script
ExecStartPost=/bin/bash /usr/sdo/bin/updateIPTable.sh
ExecStartPost=/bin/bash /usr/sdo/bin/updateNodePolicy.sh
```

Clone `hellosally-ecc` repo.
``` bash
git clone https://eos2git.cec.lab.emc.com/ISG-Edge/hellosally-ecc.git
```

Create the below scripts in `/usr/sdo/bin` to update IP table entry:

NOTE: Again, this is assuming that you cloned HelloSally repository

``` bash
cd /usr/sdo/bin
cp <HELLOSALLY-ECC_Dir>/sdo/updateIPTable.sh .
chmod +x updateIPTable.sh
```

``` bash
cd /usr/sdo/bin
cp <HELLOSALLY-ECC_Dir>/sdo/updateNodePolicy.sh .
cp <HELLOSALLY-ECC_Dir>/sdo/nodePolicy.json
chmod +x updateNodePolicy.sh
```

Register the service to start SDO on reboot

``` bash
cp /usr/sdo/sdo_to.service /lib/systemd/system
systemctl enable sdo_to.service
```

#### Unregister the node

Add node unregister script and execute `unRegisterNode.sh` manually. This will clean all agreements and policies with the management hub.

Edit the script and replace $HZN_AUTH with username:password for your system

``` bash
cd <HELLOSALLY-ECC_Dir>/sdo/
chmod +x unRegisterNode.sh
./unRegisterNode.sh
```

Please note: docker login has to be done manually to pull images from artifactory during deployment of services.
```
docker login -u <SVC-USER> -p <PASSWORD> amaas-eos-mw1.cec.lab.emc.com:5070
```

Update docker daemon with the following subnet for docker bridge to use

``` bash
echo '{
  "bip": "172.200.0.1/16"
}' > /etc/docker/daemon.json 
``` 

The device is ready and reboot now to begin SDO
