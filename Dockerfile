FROM resin/raspberrypi3-debian:latest AS build
MAINTAINER orbsmiv@hotmail.com

RUN [ "cross-build-start" ]

ARG VERSION="3.9.0"

# Set environment variables
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
        apt-get install -y --no-install-recommends \
          alsa-base \
          libicu-dev \
          libasound2-dev \
          libjack-jackd2-dev \
          libsamplerate0-dev \
          libsndfile1-dev \
          libreadline-dev \
          libxt-dev \
          libudev-dev \
          libavahi-client-dev \
          libfftw3-dev \
          make \
          cmake \
          git \
          gcc-4.8 \
          g++-4.8

RUN mkdir /tmp/supercollider-compile \
        # && git clone --recursive --depth 1 git://github.com/supercollider/supercollider /tmp/supercollider-compile \
        && git clone --recursive --depth 1 --branch ${VERSION} git://github.com/supercollider/supercollider /tmp/supercollider-compile

WORKDIR /tmp/supercollider-compile

RUN /bin/sed -i'' "s@mTimer.cancel();@if (error==boost::system::errc::success) {mTimer.cancel();} else {return;}@" lang/LangSource/SC_TerminalClient.cpp

RUN mkdir /tmp/supercollider-compile/build

WORKDIR /tmp/supercollider-compile/build

# RUN export CC=/usr/bin/gcc-4.8 \
#         && export CXX=/usr/bin/g++-4.8

ARG CC=/usr/bin/gcc-4.8
ARG CXX=/usr/bin/g++-4.8

RUN cmake -L \
            -DCMAKE_BUILD_TYPE="Release" \
            -DBUILD_TESTING=OFF \
            -DSUPERNOVA=OFF \
            -DNATIVE=OFF \
            -DSC_WII=OFF \
            -DSC_IDE=OFF \
            -DSC_QT=OFF \
            -DSC_ED=OFF \
            -DSC_EL=OFF \
            -DSC_VIM=ON \
            .. \
        && make -j 4 \
        && make install \
        && ldconfig \
        && cd /

# RUN mv /usr/local/share/SuperCollider/SCClassLibrary/Common/GUI /usr/local/share/SuperCollider/SCClassLibrary/scide_scqt/GUI \
        # && mv /usr/local/share/SuperCollider/SCClassLibrary/JITLib/GUI /usr/local/share/SuperCollider/SCClassLibrary/scide_scqt/JITLibGUI

RUN [ "cross-build-end" ]

FROM orbsmiv/jackaudiojack2-rpi:latest

RUN [ "cross-build-start" ]

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
        apt-get install -y --no-install-recommends \
        libfftw3-3 \
        supervisor \
        && apt-get clean \
        && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
        && rm -rf /tmp/supercollider-compile

COPY --from=build /usr/local/include/SuperCollider /usr/local/include/SuperCollider
COPY --from=build /usr/local/share/SuperCollider /usr/local/share/SuperCollider
COPY --from=build /usr/local/lib/SuperCollider /usr/local/lib/SuperCollider
COPY --from=build /usr/local/bin/scsynth /usr/local/bin/scsynth
COPY --from=build /usr/local/bin/sclang /usr/local/bin/sclang
COPY --from=build /usr/local/share/doc/SuperCollider/examples /usr/local/share/doc/SuperCollider/examples
COPY --from=build /usr/local/share/pixmaps/supercollider.png /usr/local/share/pixmaps/supercollider.png
COPY --from=build /usr/local/share/pixmaps/supercollider.xpm /usr/local/share/pixmaps/supercollider.xpm
COPY --from=build /usr/local/share/pixmaps/sc_ide.svg /usr/local/share/pixmaps/sc_ide.svg
COPY --from=build /usr/local/share/mime/packages/supercollider.xml /usr/local/share/mime/packages/supercollider.xml

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/supervisord"]

RUN [ "cross-build-end" ]
