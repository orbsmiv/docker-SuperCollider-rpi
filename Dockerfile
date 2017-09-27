FROM orbsmiv/jackaudiojack2-rpi:latest
MAINTAINER orbsmiv@hotmail.com

RUN [ "cross-build-start" ]

# Set environment variables
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
        apt-get install -y --no-install-recommends \
          alsa-base \
          libicu-dev \
          libasound2-dev \
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
          g++-4.8 \
        && mkdir /tmp/supercollider-compile \
        && git clone --recursive --depth 1 git://github.com/supercollider/supercollider /tmp/supercollider-compile \
        && cd /tmp/supercollider-compile \
        && mkdir build \
        && cd ./build \
        && export CC=/usr/bin/gcc-4.8 \
        && export CXX=/usr/bin/g++-4.8 \
        && cmake -L \
            -DCMAKE_BUILD_TYPE="Release" \
            -DBUILD_TESTING=OFF \
            -DSSE=OFF \
            -DSSE2=OFF \
            -DSUPERNOVA=OFF \
            -DNATIVE=OFF \
            -DSC_WII=OFF \
            -DSC_IDE=OFF \
            -DSC_QT=OFF \
            -DSC_ED=OFF \
            -DSC_EL=OFF \
            -DSC_VIM=OFF \
            .. \
        && make -j 4 \
        && make install \
        && ldconfig \
        && cd / \
        && mv /usr/local/share/SuperCollider/SCClassLibrary/Common/GUI /usr/local/share/SuperCollider/SCClassLibrary/scide_scqt/GUI \
        && mv /usr/local/share/SuperCollider/SCClassLibrary/JITLib/GUI /usr/local/share/SuperCollider/SCClassLibrary/scide_scqt/JITLibGUI \
        && apt-get purge \
          libicu-dev \
          libasound2-dev \
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
          g++-4.8 \
        && apt-get clean \
        && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
        && rm -rf /tmp/supercollider-compile \

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

RUN [ "cross-build-end" ]
