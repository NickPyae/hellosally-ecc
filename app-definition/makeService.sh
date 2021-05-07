#!/bin/bash
set -e
source .env
export DEVICE_SERVICE_CONFIG=$(jq -c . < device-service.config.json | sed 's/"/\\\\"/g')
echo $DEVICE_SERVICE_CONFIG
sed "s|{{ DEVICE_SERVICE_JSON }}|$DEVICE_SERVICE_CONFIG|g" services/hellosally.service.json.tmpl > hellosally.service.json
sed -i "s|{{ KUIPER_READING_NAME }}|$KUIPER_READING_NAME|g" hellosally.service.json
sed -i "s|{{ KUIPER_IP }}|$KUIPER_IP|g" hellosally.service.json
sed -i "s|{{ KUIPER_PORT }}|$KUIPER_PORT|g" hellosally.service.json
sed -i "s|{{ INFLUXDB_IP }}|$INFLUXDB_IP|g" hellosally.service.json
sed -i "s|{{ INFLUXDB_PORT }}|$INFLUXDB_PORT|g" hellosally.service.json
sed -i "s|{{ INFLUXDB_TOKEN }}|$INFLUXDB_TOKEN|g" hellosally.service.json
sed -i "s|{{ INFLUXDB_CLOUD_TOKEN }}|$INFLUXDB_CLOUD_TOKEN|g" hellosally.service.json
sed -i "s|{{ BUCKET_NAME }}|$BUCKET_NAME|g" hellosally.service.json
sed -i "s|{{ REDIS_IP }}|$REDIS_IP|g" hellosally.service.json
sed -i "s|{{ REDIS_PORT }}|$REDIS_PORT|g" hellosally.service.json
