#!/usr/bin/env ash

# Define the jackd server options - see https://github.com/jackaudio/jackaudio.github.com/wiki/jackdrc(5)
echo "/usr/bin/jackd -m -R -p 32 -T -d alsa -d ${ALSA_DEV} \"-n 3\" \"-i ${CH_IN}\" \"-o ${CH_OUT}\" \"-p ${HW_BUFF}\" \"-r ${SR}\" -P -s" > /etc/jackdrc

exec "$@"
