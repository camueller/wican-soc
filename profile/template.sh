#!/bin/bash
# Use this file as template for new profiles.

template_send_soc_request() {
  # mosquitto_pub is passed as $1
  $1 -m "{\"bus\":\"0\",\"type\":\"tx\",\"frame\":[...]}"
}

template_response_message_count() {
  # return the number of CAN=MQTT messages to wait for
  return 1
}

template_parse_soc_response() {
  # the fully qualified file containing the CAN=MQTT messages is passed as $1
  # return the SoC extracted from this file
  return 33
}

