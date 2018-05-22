#!/bin/sh

set -e

CONN_PATH="/usr/local/bin/jack_connect"

while ! /usr/local/bin/jack_lsp | /bin/grep -F "SuperCollider" > /dev/null; do
  /bin/echo "Waiting for SuperCollider ports"
  /bin/sleep 1
done

if ((${CH_OUT} > 0)); then
  for i in $(seq 1 ${CH_OUT}); do
    $CONN_PATH SuperCollider:out_$i system:playback_$i ;
  done;
fi

if ((${CH_IN} > 0)); then
  for i in $(seq 1 ${CH_IN}); do
    $CONN_PATH SuperCollider:in_$i system:capture_$i ;
  done;
fi

sleep 1

exit 0
