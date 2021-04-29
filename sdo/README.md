# Open Horizon SDO

Open horizon integration with Intel SDO framework. 
1. Horizon management hub with customer service
2. Agent node with device credentials 
3. RV server

### On management hub (ECC)

Setup and Run management hub with customer service

A management hub server is bundled with the owner service docker container. Please refer to the docker-compose.yml.template file.
On make build, owner service docker will be running and listening to TO0, TO1 , and TO2 protocol execution. 
Please refer to this confluence for more details about these protocol specifications. https://confluence.cec.lab.emc.com/display/ISGPDE/SDO+-+Secure+Device+Onboard

#### How to import voucher:

An ownership voucher is a file that the device manufacturer gives to the purchaser (owner) along with the physical device. 

An hzn voucher sub-command to import one or more ownership vouchers into a horizon instance

``` bash
cd /root
mkdir devices
cd devices
mkdir <DEVICE_ID>
cd <DEVICE_ID>
vi voucher.json #(copy contents from ownership voucher) 
```

Import Voucher:

``` bash
export SDO_RV_URL=http://sdo-sbx.trustedservices.intel.com:80
export HZN_SDO_SVC_URL=http://192.168.2.150:9008/api
hzn voucher import voucher.json
```

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

This outputs DEVICE ID and Ownership Voucher location. Copy the contents of the ownership voucher and proceed to import the voucher in the management VM.
[Please refer](#How-to-import-voucher)

The above process add owner-boot-device script in /var/sdo/bin directory and creates a service definition sdo_to in /var/sdo

Update the service definition by adding postscripts to update IP tables. This is a workaround for management control agent VM.

Add the below line in service file:

``` bash
cd /usr/sdo
vi sdo_to.service
#Add the below line after ExecStart command as a post processing script
ExecStartPost=/bin/bash /usr/sdo/bin/updateIPTable.sh
```

Create the below script to update IP table entry:

NOTE: Again, this is assuming that you cloned HelloSally repository

``` bash
cd /usr/sdo/bin
cp <hellosallyrepo_Dir>/open-horizon-integration/hub/oh/sdo/updateIPTable.sh .
chmod +x updateIPTable.sh
```

Add node unregister script. This is clean all agreements and policies with the management hub.

``` bash
cd /usr/sdo/bin
cp <hellosallyrepo_Dir>/open-horizon-integration/hub/oh/sdo/unRegisterNodeAndReboot.sh .
chmod +x unRegisterNodeAndReboot.sh
```

Please note: docker login has to be done manually to pull images from artifactory 
```
docker login -u <SVC-USER> -p <PASSWORD> amaas-eos-mw1.cec.lab.emc.com:5070
```

The device is ready and reboot now to begin SDO
