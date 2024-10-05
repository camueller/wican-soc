# Create a new profile for a vehicle manufacturer or model

The profiles are located in the `profile` directory. For each profile there must be a file with the profile name and the extension `.sh`.

The creation of new profiles should start from the profile `template.sh`, which also contains some hints.

Each profile must provide the following functions:

## `<profile name>_send_soc_request` (example: `nissan_send_soc_request`)
This function needs to send the MQTT message to the WiCAN, which causes the vehicle to send a response with the SoC.

The function receives an almost fully configured call to `mosquitto_pub` as `$1`. All that remains is to add the parameter `-m <MQTT message>`, whereby the quotation marks within the JSON message must be preceded by a backslash character.

## `<profile name>_response_message_count` (example: `nissan_response_message_count`)
This function only needs to return the number of MQTT messages that make up the vehicle's response. In most cases this is probably 1. This is required so that the MQTT client waits for the appropriate number of MQTT messages before starting to process them.

## `<profile name>_parse_soc_response` (example: `nissan_parse_soc_response`)
This function must determine the SoC from the vehicle's MQTT message(s). To do this, the function receives the path and name of the file that contains the MQTT message(s).

The usual Unix tools (`grep`, `sed`, ...) can be used to access certain parts of the file. However, because the MQTT message(s) are in JSON format, the JSON processor `jq` is better suited for this within a line.

The bytes of the CAN message are located in the `data` array of the `frame` attribute. The bytes necessary for calculating the SoC can be extracted with `jq .frame[0].data[Byte-Index]`, where `Byte-Index` can have the values 0 to 7.

The command line calculator tool `bc` can also be used to calculate the SoC if the mathematical capabilities of the Bash shell are not sufficient. See also [bc command in Linux with examples](https://www.geeksforgeeks.org/bc-command-linux-examples/) and [bc - an arbitrary precision calculator language](https://www.gnu.org/software/bc/manual/html_mono/bc.html).