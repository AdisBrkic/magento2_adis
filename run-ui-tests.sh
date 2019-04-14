#!/bin/bash
set -e

export VERSION=`jq .[0].release SHOPVERSIONS`

curl -s https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip > ngrok.zip
unzip ngrok.zip
chmod +x $PWD/ngrok

curl -sO http://stedolan.github.io/jq/download/linux64/jq
chmod +x $PWD/jq

TIMESTAMP=$(date +%s)
$PWD/ngrok http 9090 -subdomain="${TIMESTAMP}-magento2-api-test" > /dev/null &

NGROK_URL=$(curl -s localhost:4040/api/tunnels/command_line | jq --raw-output .public_url)

while [ ! ${NGROK_URL} ] || [ ${NGROK_URL} = 'null' ];  do
    echo "Waiting for ngrok to initialize"
    export NGROK_URL=$(curl -s localhost:4040/api/tunnels/command_line | jq --raw-output .public_url)
    echo $NGROK_URL
    sleep 20
done

bash start-shopsystem.sh