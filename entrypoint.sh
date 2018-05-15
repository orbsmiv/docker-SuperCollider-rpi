#!/bin/sh

# /usr/local/bin/jackd -P75 -dalsa -dhw:1 -p1024 -n3 -s -r44100
# /usr/local/bin/jackd -m -r -d alsa -d hw:0 -p 1024 -n 3 -s -r 48000 -P


# exec /usr/local/bin/sclang "$@"
exec "$@"
