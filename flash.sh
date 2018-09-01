#!/bin/bash

set -eux
shopt -s nullglob

docker build -t euank/keyboardio:latest .

if [[ $# == "1" ]]; then
  if [[ -L "$1" ]]; then
    dev="$1"
  fi
  echo "Usage: $0 [</dev/serial/by-id/usb-Keyboardio_Model_01....>]"
  exit 1
else
  keyboardios=( /dev/serial/by-id/usb-Keyboardio_Model_01_* )
  if [[ "${#keyboardios[@]}" != 1 ]]; then
    echo "Detected ${#keyboardios[@]}; is it in /dev/serial/by-id?"
    exit 1
  fi
  dev="${keyboardios[0]}"
fi

if [[ -L "$dev" ]]; then
  dev="$(readlink -f "$dev")"
fi


docker run \
  --device "$dev" \
  -v /dev/serial:/dev/serial \
  -v "${PWD}:/root/Arduino/hardware/keyboardio/avr/libraries/Kaleidoscope" \
  --rm \
  -it \
  euank/keyboardio:latest \
  make flash KALEIDOSCOPE_DEV_PORT="$dev" KALEIDOSCOPE_DEV_BOOTLOADER_PORT="$dev"
