FROM ubuntu:20.04

ENV DEBIAN_FRONTEND noninteractive
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

RUN apt-get update \
 && apt-get install -yq --no-install-recommends \
    build-essential bzip2 cmake ffmpeg git g++ \
    libasound2 libassimp-dev libavcodec-extra libboost-dev \
    libdbus-1-3 libfreeimage-dev libfreetype6-dev \
    libgd-dev libglu1-mesa-dev libglib2.0-dev libgl1-mesa-dev libgl1-mesa-glx \
    libjpeg8-dev libnspr4 libnss3 libpci-dev libpng-dev libreadline-dev \
    libspatialindex-dev libssh-gcrypt-dev libssh-4 libssl-dev libtiff5-dev \
    libusb-dev libxcomposite1 libxcursor1 libxkbcommon-x11-dev libxi6 \
    libxrender1 libxss1 libxml2-dev libxslt1-dev libzip-dev libzzip-0-13 \
    locales lsb-release mesa-utils npm openjdk-8-jdk pbzip2 \
    python3-pip python3-setuptools python3-venv python3-dev \
    swig unzip wget xpra xorg-dev xserver-xorg-video-dummy xvfb zip \
    libxkbcommon-x11-0 \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

RUN rm -f /usr/bin/python && ln -s /usr/bin/python3.8 /usr/bin/python

SHELL ["/bin/bash", "-c"]

ENV SHELL=/bin/bash \
 	NB_USER=jovyan \
 	NB_UID=1000 \
 	LANG=en_US.UTF-8 \
 	LANGUAGE=en_US.UTF-8

ENV HOME=/home/${NB_USER}

RUN adduser --disabled-password \
 	--gecos "Default user" \
 	--uid ${NB_UID} \
 	${NB_USER}

USER ${NB_USER}

WORKDIR ${HOME}

#
# See https://pypi.org/project/opencv-python/
# Need to upgrade pip to insure that opencv is installed correctly
# 
ENV ENVDIR=${HOME}/wlenv
RUN python3 -m venv ${ENVDIR} \
 && source ${ENVDIR}/bin/activate \
 && pip install --upgrade pip \
 && pip -V \
 && pip install ikpy jupyterlab matplotlib numpy opencv-python pillow rtree shapely

RUN wget --no-check-certificate https://github.com/cyberbotics/webots/releases/download/R2022a/webots-R2022a-x86-64.tar.bz2 \
 && tar xjf webots-R2022a-x86-64.tar.bz2 \
 && rm webots-R2022a-x86-64.tar.bz2

ADD --chown=1000:1000 notebooks/ ${ENVDIR}/notebooks/
ADD --chown=1000:1000 projects/ ${ENVDIR}/projects/
ADD --chown=1000:1000 stream/ ${ENVDIR}/stream/

ADD --chown=1000:1000 conf/Webots-R2020a.conf ${HOME}/.config/Cyberbotics/
ADD --chown=1000:1000 WebotsLab_in_Docker.bash ${HOME}/

USER 0
RUN apt-get update \
 && apt-get install -yq --no-install-recommends \
 '^libxcb.*-dev' libx11-xcb-dev libglu1-mesa-dev libxrender-dev libxi-dev libxkbcommon-dev libxkbcommon-x11-dev \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*
USER ${NB_USER}



CMD ["./WebotsLab_in_Docker.bash"]

EXPOSE 1234
EXPOSE 8888
EXPOSE 8889
