#!/bin/bash

# If node is registered (if you have run this script before), then unregister it
if which hzn >/dev/null; then
    nodeId=`hzn node list | grep -Po '"id": *\K"[^"]*"' | sed 's/"//g'`
    if [[ $(hzn node list 2>&1 | jq -r '.configstate.state' 2>&1) == 'configured' ]]; then
        hzn unregister -f
    fi
    echo $nodeId
    export HZN_EXCHANGE_USER_AUTH=$HZN_AUTH
    yes | hzn exchange node remove $nodeId -o dellsg
fi

cp /usr/sdo/sdo_to.service /lib/systemd/system
systemctl enable sdo_to.service
