
#!/bin/bash
while read -r f ; do source "$f" ;  done < <(find ./profile -type f)
. ./config

PROFILES=`ls -p ./profile | grep -v / | sed 's/\.sh//g' | tr '\n' ' '`
CAN_MESSAGE_FILE=/tmp/can-message.txt
MQTT_SUB="mosquitto_sub -h $MQTT_SERVER -t wican/$WICAN_DEVICE_ID/can/rx"
MQTT_PUB="mosquitto_pub -h $MQTT_SERVER -t $MQTT_SOC_TOPIC"

if [[ $PROFILES =~ (^| )$PROFILE($| ) ]]; then
    echo "Using profile $PROFILE for WiCAN device $WICAN_DEVICE_ID"

    RESPONSE_MESSAGE_COUNT_FUNC="$PROFILE"_response_message_count
    $RESPONSE_MESSAGE_COUNT_FUNC
    RESPONSE_MESSAGE_COUNT=$?
    echo "Expecting response to consist of $RESPONSE_MESSAGE_COUNT CAN message(s)"

    while true; do
        echo "Waiting for messages ..."
        $MQTT_SUB -C $RESPONSE_MESSAGE_COUNT > $CAN_MESSAGE_FILE
        echo "Message received:"
        cat $CAN_MESSAGE_FILE

        FUNC="$PROFILE"_parse_soc_response
        echo "Parsing SOC response ..."
        $FUNC "$CAN_MESSAGE_FILE"
        SOC=$?
        echo "SOC=$SOC"

        if [ -n "$SOC" ]; then
            TIMESTAMP=`date --iso-8601=seconds`
            MQTT_SOC_MESSAGE="{\"soc\":$SOC, \"time\":\"$TIMESTAMP\"}"
            echo "Publishing SOC MQTT message ..."
            $MQTT_PUB -r -m "$MQTT_SOC_MESSAGE"
        fi
        echo "Sleeping ..."
        sleep 10
    done
else
    echo "ERROR: Check PROFILE variable. There is no profile named $PROFILE"
fi
