# FROM resin/raspberrypi3-debian:latest AS build
FROM orbsmiv/jackaudiojack2-rpi:latest AS build
MAINTAINER orbsmiv@hotmail.com

RUN [ "cross-build-start" ]

ARG VERSION="Version-3.10.2"

# Set environment variables
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
        apt-get install -y --no-install-recommends \
          libicu-dev \
          libasound2-dev \
          libsamplerate0-dev \
          libsndfile1-dev \
          libreadline-dev \
          libxt-dev \
          libudev-dev \
          libfftw3-dev \
          make \
          cmake \
          git \
          gcc \
          g++

RUN mkdir /tmp/supercollider-compile \
        && git clone --recursive --depth 1 --branch ${VERSION} \
        git://github.com/supercollider/supercollider \
        /tmp/supercollider-compile

WORKDIR /tmp/supercollider-compile

RUN mkdir /tmp/supercollider-compile/build

WORKDIR /tmp/supercollider-compile/build

ARG CC=/usr/bin/gcc
ARG CXX=/usr/bin/g++

RUN cmake -L \
            -DCMAKE_BUILD_TYPE="Release" \
            -DBUILD_TESTING=OFF \
            -DENABLE_TESTSUITE=OFF \
            -DSUPERNOVA=OFF \
            -DNATIVE=OFF \
            -DSC_WII=OFF \
            -DSC_IDE=OFF \
            -DSC_QT=OFF \
            -DSC_ED=OFF \
            -DSC_EL=OFF \
            -DINSTALL_HELP=OFF \
            -DSC_VIM=ON \
            -DNO_AVAHI=ON \
            -DNO_X11=ON \
            .. \
        && make -j $(nproc) \
        && make install \
        && ldconfig \
        && cd /

# RUN mv /usr/local/share/SuperCollider/SCClassLibrary/Common/GUI /usr/local/share/SuperCollider/SCClassLibrary/scide_scqt/GUI \
        # && mv /usr/local/share/SuperCollider/SCClassLibrary/JITLib/GUI /usr/local/share/SuperCollider/SCClassLibrary/scide_scqt/JITLibGUI

RUN mkdir /tmp/supercollider-plugs-compile \
        && git clone --recursive --depth 1 \
        git://github.com/supercollider/sc3-plugins \
        /tmp/supercollider-plugs-compile

RUN mkdir /tmp/supercollider-plugs-compile/build

WORKDIR /tmp/supercollider-plugs-compile/build

RUN cmake -L \
            -DCMAKE_BUILD_TYPE="Release" \
            -DSUPERNOVA=OFF \
            -DNATIVE=OFF \
            -DSC_PATH=/tmp/supercollider-compile/ \
            .. \
        && make -j $(nproc) \
        && make install

RUN [ "cross-build-end" ]

FROM orbsmiv/jackaudiojack2-rpi:latest

RUN [ "cross-build-start" ]

ARG DEBIAN_FRONTEND=noninteractive

ENV TINI_VERSION="v0.18.0"

ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-armhf /tini
RUN chmod +x /tini

RUN apt-get update && \
        apt-get install -y --no-install-recommends \
        libfftw3-3 \
        libsndfile1 \
        && apt-get clean \
        && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
        && rm -rf /tmp/supercollider-compile

COPY --from=build /usr/local/include/SuperCollider /usr/local/include/SuperCollider
COPY --from=build /usr/local/share/SuperCollider /usr/local/share/SuperCollider
COPY --from=build /usr/local/lib/SuperCollider /usr/local/lib/SuperCollider
COPY --from=build /usr/local/bin/scsynth /usr/local/bin/scsynth
COPY --from=build /usr/local/bin/sclang /usr/local/bin/sclang
#COPY --from=build /usr/local/share/doc/SuperCollider/examples /usr/local/share/doc/SuperCollider/examples
COPY --from=build /usr/local/share/pixmaps/supercollider.png /usr/local/share/pixmaps/supercollider.png
COPY --from=build /usr/local/share/pixmaps/supercollider.xpm /usr/local/share/pixmaps/supercollider.xpm
COPY --from=build /usr/local/share/pixmaps/sc_ide.svg /usr/local/share/pixmaps/sc_ide.svg
COPY --from=build /usr/local/share/mime/packages/supercollider.xml /usr/local/share/mime/packages/supercollider.xml

COPY docker-entrypoint.sh /docker-entrypoint.sh 
RUN chmod +x /docker-entrypoint.sh

# Env vars for jackd
ENV JACK_START_SERVER=true \
    SC_JACK_DEFAULT_INPUTS=system \
    SC_JACK_DEFAULT_OUTPUTS=system

# Env vars for scsynth init
ENV CH_OUT=2 \
    CH_IN=2 \
    SC_SYNTH_PORT=57110 \
    SR=48000 \
    SC_BLOCK=128 \
    HW_BUFF=2048 \
    SC_MEM=131072 \
    ALSA_DEV="hw:0"

ENTRYPOINT ["/tini", "--", "/docker-entrypoint.sh"]
CMD ["/bin/sh", "-c", "/usr/local/bin/scsynth", "-u", "${SC_SYNTH_PORT}", "-m", "${SC_MEM}", "-D", "0", "-R", "0", "-i", "${CH_IN}", "-o", "${CH_OUT}", "-z", "${SC_BLOCK}"]

RUN [ "cross-build-end" ]
