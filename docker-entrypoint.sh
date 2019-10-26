#!/usr/bin/env ash

# Define the jackd server options - see https://github.com/jackaudio/jackaudio.github.com/wiki/jackdrc(5)
BASE_OPTIONS="/usr/bin/jackd -m -R -p 32 -T --driver alsa"

ALSA_OPTIONS="--device ${ALSA_DEV} \"--nperiods 3\" \"-i ${CH_IN}\" \"-o ${CH_OUT}\" \"--period ${HW_BUFF}\" \"--rate ${SR}\" --softmode"

if [ "${SHORTS}" = "true" ]; then
    ALSA_OPTIONS="${ALSA_OPTIONS} --shorts"
fi

if [ "${CH_IN}" -lt "1" ]; then
    ALSA_OPTIONS="${ALSA_OPTIONS} --playback"
fi

if [ "${CH_OUT}" -lt "1" ]; then
    ALSA_OPTIONS="${ALSA_OPTIONS} --capture"
fi

echo "${BASE_OPTIONS}" "${ALSA_OPTIONS}" > "${HOME}"/.jackdrc

exec "$@"
