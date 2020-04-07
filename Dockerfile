FROM nvidia/opengl:1.0-glvnd-runtime-ubuntu18.04

################################## JUPYTERLAB ##################################

ENV DEBIAN_FRONTEND noninteractive
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

RUN apt-get update \
 && apt-get install -yq --no-install-recommends \
    build-essential bzip2 cmake git locales \
    python3-pip python3-setuptools wget \ 
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

RUN pip3 install --upgrade pip setuptools \
 && python3 -m pip install jupyterlab rpyc

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

EXPOSE 8888

CMD ["jupyter", "lab", "--no-browser", "--ip=0.0.0.0", "--NotebookApp.token=''"]

#################################### WEBOTS ####################################

RUN wget --no-check-certificate https://github.com/cyberbotics/webots/releases/download/R2019a/webots-R2018b-x86-64.tar.bz2 \

 && tar xjf webots-R2018b-x86-64.tar.bz2 \
 && rm webots-R2018b-x86-64.tar.bz2

USER root

RUN apt-get update \
 && apt-get install -yq --no-install-recommends \
    openjdk-8-jdk git g++ cmake libusb-dev swig python2.7-dev \
    libglu1-mesa-dev libglib2.0-dev libfreeimage-dev libfreetype6-dev \
    libxml2-dev libzzip-0-13 libssh-gcrypt-dev libssl1.0-dev libboost-dev \
    libjpeg8-dev libavcodec-extra libpci-dev libgd-dev libtiff5-dev libzip-dev \
    libreadline-dev libassimp-dev libpng-dev ffmpeg python3.6-dev \
    python3.7-dev npm libxslt1-dev libssh-4 pbzip2 \
    lsb-release wget unzip zip libnss3 libnspr4 libxcomposite1 libxcursor1 \
    libxi6 libxrender1 libxss1 libasound2 libdbus-1-3 xserver-xorg-video-dummy \
    xpra xorg-dev libgl1-mesa-dev mesa-utils libgl1-mesa-glx xvfb libxkbcommon-x11-dev \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

RUN rm /usr/bin/python && ln -s /usr/bin/python3.6 /usr/bin/python

USER ${NB_USER}

ADD --chown=1000:1000 notebooks/ ${HOME}/notebooks/
ADD --chown=1000:1000 projects/ ${HOME}/projects/

#ADD --chown=1000:1000 Webots-R2020a.conf ${HOME}/.config/Cyberbotics/

ENV WEBOTS_HOME=${HOME}/webots

ENV LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${WEBOTS_HOME}/lib:${WEBOTS_HOME}/lib/controller \
    PYTHONPATH=${PYTHONPATH}:${WEBOTS_HOME}/lib/python36:${WEBOTS_HOME}/lib/controller/python36 \
    PYTHONIOENCODING=UTF-8

CMD ["jupyter", "lab", "--no-browser", "--ip=0.0.0.0", \
     "--NotebookApp.token=''", "--NotebookApp.notebook_dir='notebooks'" ]
