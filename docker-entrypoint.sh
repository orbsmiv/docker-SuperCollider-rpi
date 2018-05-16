#!/bin/bash
set -e

# if [ "$1" = 'postgres' ]; then
#     chown -R postgres "$PGDATA"
#
#     if [ -z "$(ls -A "$PGDATA")" ]; then
#         gosu postgres initdb
#     fi
#
#     exec gosu postgres "$@"
# fi
#
# exec "$@"

jackd -m -r -p 32 -T -d alsa -d hw:0 -n 3 -o 2 -p 2048 -P -r 48000 -s &

sleep 3

exec scsynth -u 57150 -m 131072 -D 0 -R 0 -o 2 -z 128 &

sleep 3

jack_connect SuperCollider:out_1 system:playback_1 && jack_connect SuperCollider:out_2 system:playback_2
