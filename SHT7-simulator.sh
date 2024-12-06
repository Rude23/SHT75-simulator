#!/bin/bash

function interrupt(){
    echo "CTRL+C detected. Cleaning up and exiting..."
    exit $?
}

function display_usage() {
    echo "$NAME is a simple script to simulate SHT75 data stream sampled through an Artix-7 FPGA"
    echo "developed as a tool for studying data acquisition required in lab classes for \"università degli studi di Napoli Federico II\""
    echo "LM17 master degree during A.A. 2024-2025"
    echo ""
    echo "Usage: $NAME {[-p --port] [-d --debug] [-t --period] | -h --help}"
    echo "Options:"
    echo "  -d --debug   : enable debug"
    echo "Arguments:"
    echo "  -p --port    : (virtual) usb port to write bytes to"
    echo "  -t --period  : Specify the period (in seconds) for a full data (end-word, T, HR) sampling cycle"
}

trap interrupt SIGINT

NAME="SHT75-simulator"
DEBUG=

VALID_ARGS=$(getopt -o hdp:t: --long help,debug,period:,port: -- "$@")
if [[ $? -ne 0 ]]; then
    exit 1;
fi

eval set -- "$VALID_ARGS"
while [ : ]; do
  case "$1" in
    -d | --debug)
        DEBUG="-d"
        shift
        ;;
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
        display_usage
        exit 0
        ;;
    *)
        break
        ;;
  esac
done

if [[ -z "$PERIOD" ]]; then
    display_usage
    exit 1;
fi

if [[ -z "$PORT" ]]; then
    display_usage
    exit 1;
fi
echo "Streaming simulated SHT75 data with period of $PERIOD seconds"

while :
  do
    ## TODO: group repeated code
    BEGIN=$(date +%s%3N);
    printf "%b" '\xaa\xaa' > "$PORT";
    TIME_ELAPSED=$(($(date +%s%3N) - BEGIN))
    sleep "$(LC_NUMERIC=C awk 'BEGIN {printf "%.3f", ('"$PERIOD"' - '"$TIME_ELAPSED"'/1000)/5}')"

    printf "%b" "\x$(hexdump -vn 1 -e '1/1 "%02x"' /dev/urandom)" > "$PORT";
    TIME_ELAPSED=$(($(date +%s%3N) - BEGIN))
    sleep "$(LC_NUMERIC=C awk 'BEGIN {printf "%.3f", ('"$PERIOD"' - '"$TIME_ELAPSED"'/1000)/4}')"

    printf "%b" "\x$(hexdump -vn 1 -e '1/1 "%02x"' /dev/urandom)" > "$PORT";
    TIME_ELAPSED=$(($(date +%s%3N) - BEGIN))
    sleep "$(LC_NUMERIC=C awk 'BEGIN {printf "%.3f", ('"$PERIOD"' - '"$TIME_ELAPSED"'/1000)/3}')"

    printf "%b" "\x$(hexdump -vn 1 -e '1/1 "%02x"' /dev/urandom)" > "$PORT";
    TIME_ELAPSED=$(($(date +%s%3N) - BEGIN))
    sleep "$(LC_NUMERIC=C awk 'BEGIN {printf "%.3f", ('"$PERIOD"' - '"$TIME_ELAPSED"'/1000)/2}')"

    printf "%b" "\x$(hexdump -vn 1 -e '1/1 "%02x"' /dev/urandom)" > "$PORT";
    TIME_ELAPSED=$(($(date +%s%3N) - BEGIN))
    sleep "$(LC_NUMERIC=C awk 'BEGIN {printf "%.3f", ('"$PERIOD"' - '"$TIME_ELAPSED"'/1000)}')"

    TIME_ELAPSED=$(($(date +%s%3N) - BEGIN))
    if [[ -n $DEBUG ]]
    then
      echo "simulated full word in $TIME_ELAPSED ms"
    fi
  done
