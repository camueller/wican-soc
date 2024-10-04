#!/bin/bash

vw_send_soc_request() {
  $1 "Perform requsts for vw using command $1"
}

vw_response_message_count() {
  return 1;
}

vw_parse_soc_response() {
  echo "Parse response for vw ..."
  return 33
}

