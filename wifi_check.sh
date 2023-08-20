#!/bin/bash

while true; do

  # Define paths
  SCRIPT_DIR=$(dirname "$0")
  USB_RESET_SCRIPT="$SCRIPT_DIR/usb_reset"

  # Replace "RTL88x2bu" with the name of the device you want to reset
  CURRENT_USB_BUS=$(lsusb | grep RTL88x2bu | awk '{print $2}')
  CURRENT_USB_PORT=$(lsusb | grep RTL88x2bu | awk '{print $4}')

  USB_PATH="/dev/bus/usb/$CURRENT_USB_BUS/$CURRENT_USB_PORT"
  LOG_FILE="$SCRIPT_DIR/reset_script.log"
  LOG_REDUCE_SCRIPT="$SCRIPT_DIR/reduce_log.sh"

  # Get WiFi device status | Replace "wlx90de80ae8d61" with the name of your Wi-Fi adapter
  wifi_status=$(nmcli device show wlx90de80ae8d61 | awk -F": " '/GENERAL.STATE/ {gsub(/^[ \t]+|[()0-9]+/,"",$2); sub(/^[ \t]+/, "", $2); print $2}')

  if [ "$wifi_status" == "connected" ]; then
    echo "$(date): A WiFi device was found and is connected." >> "$LOG_FILE"
  elif [ "$wifi_status" == "disconnected" ]; then
    echo "$(date): A WiFi device was found, but it is disconnected. Running usb_reset..." >> "$LOG_FILE"
    echo "CURRENT_USB_BUS=$CURRENT_USB_BUS | CURRENT_USB_PORT=$CURRENT_USB_PORT"
    "$USB_RESET_SCRIPT" "$USB_PATH"
  else
    echo "$(date): No WiFi device found on $USB_PATH" >> "$LOG_FILE"
  fi

  bash "$LOG_REDUCE_SCRIPT"

  sleep 1 # Wait for 2 minutes
done
