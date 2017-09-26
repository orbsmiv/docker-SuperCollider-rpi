#!/bin/sh

/usr/local/bin/jackd -P75 -dalsa -dhw:1 -p1024 -n3 -s -r44100

exec /usr/local/bin/sclang "$@"
