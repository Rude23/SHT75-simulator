#!/bin/bash

function interrupt(){
    echo "CTRL+C detected. Cleaning up and exiting..."
    exit $?
}

function display_usage() {
    echo "$NAME is a simple script to simulate SHT75 data stream sampled through an XXXXXXXXX programmable microcontroller" #TODO: inserire nome scheda
    echo "developed as a tool for studying data acquisition required in lab classes for \"università degli studi di Napoli Federico II\""
    echo "LM17 master degree during A.A. 2024-2025"
    echo ""
    echo "Usage: $NAME {[-p --port] [-d --debug] [-t --period] | -h --help}"
    echo "Arguments:"
    echo "  -p --port     : (virtual) usb port to write bytes to"
    echo "  -t --period  : Specify the period (in seconds) for a full data (end-word, T, HR) sampling cycle"
}

trap interrupt SIGINT

NAME="SHT75-simulator"

VALID_ARGS=$(getopt -o hp:t: --long help,period:,port: -- "$@")
if [[ $? -ne 0 ]]; then
    exit 1;
fi

eval set -- "$VALID_ARGS"
while [ : ]; do
  case "$1" in
    -p | --port)
      if [ -n "$2" ]; then
        PORT=$2
        shift 2
      else
        display_usage
        exit 1
      fi
      ;;
    -t | --period)
        if [[ $2 =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
          PERIOD=$2
          shift 2
        else
          display_usage
          exit 1
        fi
        ;;
    -h | --help)
        "echo H"
        display_usage
        exit 0
        ;;
    *)
        break
        ;;
  esac
done

if [[ -z "$PERIOD" ]]; then
    "echo T"
    display_usage
    exit 1;
fi

if [[ -z "$PORT" ]]; then
    "echo P"
    display_usage
    exit 1;
fi
PERIOD_6=$(awk "BEGIN {print $PERIOD / 6}")
echo "Streaming simulated SHT75 data with period of $PERIOD seconds"

while :
do
  sleep "$PERIOD_6";
  echo -n -e 'AA' > "$PORT";
  sleep "$PERIOD_6";
  echo -n -e 'AA' > "$PORT";
  sleep "$PERIOD_6";
  hexdump -vn 1 -e '1/1 "%02x"' /dev/urandom > "$PORT";
  sleep "$PERIOD_6";
  hexdump -vn 1 -e '1/1 "%02x"' /dev/urandom > "$PORT";
  sleep "$PERIOD_6";
  hexdump -vn 1 -e '1/1 "%02x"' /dev/urandom > "$PORT";
  sleep "$PERIOD_6";
  hexdump -vn 1 -e '1/1 "%02x"' /dev/urandom > "$PORT";
done