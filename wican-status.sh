#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

while read -r f ; do source "$f" ;  done < <(find $SCRIPT_DIR/profile -type f)
. $SCRIPT_DIR/config

MQTT_SUB="mosquitto_sub -h $MQTT_SERVER -t wican/$WICAN_DEVICE_ID/status -C 1"
MQTT_PUB="mosquitto_pub -h $MQTT_SERVER -t wican/$WICAN_DEVICE_ID/can/tx"
CAN_STATUS_FILE=/tmp/can-status.txt
PROFILES=`ls -p $SCRIPT_DIR/profile | grep -v / | sed 's/\.sh//g' | tr '\n' ' '`

if [[ $PROFILES =~ (^| )$PROFILE($| ) ]]; then
    echo "Using profile $PROFILE for WiCAN device $WICAN_DEVICE_ID"
    while true; do
        echo "Waiting for message ..."
        $MQTT_SUB > $CAN_STATUS_FILE
        echo "Message received:"
        cat $CAN_STATUS_FILE
        STATUS=`cat $CAN_STATUS_FILE | jq .status | tr -d '"'`
        if [ "$STATUS" = "online" ]; then
            FUNC="$PROFILE"_send_soc_request
            echo "Sending SOC request ..."
            $FUNC "$MQTT_PUB"
        fi
        echo "Sleeping ..."
        sleep 60
    done
else
    echo "ERROR: Check PROFILE variable. There is no profile named $PROFILE"
fi
