#!/usr/bin/env bash
# usage: ./auto_telnet_gnmap.sh TARGET myscan.gnmap
TARGET="$1"
GNMAP="$2"

if [[ -z "$TARGET" || -z "$GNMAP" ]]; then
  echo "Usage: $0 TARGET myscan.gnmap"
  exit 1
fi

# extract ports like: 22/open/tcp//ssh///
ports=$(grep "/open/" "$GNMAP" | sed -n 's/.*Ports: //p' | tr ',' '\n' | awk -F'/' '{print $1}' | sort -u)

for port in $ports; do
  echo -n "Trying $TARGET:$port ... "
  # telnet will hang; use timeout. Send "quit" to politely close if connected.
  if timeout 3 bash -c "echo quit | telnet $TARGET $port" 2>/dev/null | grep -qE "Connected|Escape"; then
    echo "CONNECTED"
  else
    echo "no response"
  fi
done
