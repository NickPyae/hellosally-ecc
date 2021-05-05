#!/bin/bash
hzn policy update -f /usr/sdo/bin/nodePolicy.json
systemctl disable sdo_to.service    # so it does not run on every boot