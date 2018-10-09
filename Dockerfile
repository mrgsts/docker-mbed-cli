FROM ubuntu:18.04
MAINTAINER Jose Rodriguez <jrodriguezr@protonmail.com>
LABEL "mbed-cli + GNU GCC ARM/embedded-6-branch revision 249437"

ENV TZ=Europe/Madrid
RUN echo "Europe/Madrid" > /etc/timezone && ln -s /usr/share/zoneinfo/Europe/Madrid /etc/localtime

RUN apt-get update && apt-get install -y \
	bzip2 \
	git \
	wget \
	mercurial \
	python-pip \
	python-setuptools \
	unzip \
	vim-nox \
	sudo \
	--no-install-recommends \
	&& rm -rf /var/lib/apt/lists/* && apt clean

ADD https://developer.arm.com/-/media/Files/downloads/gnu-rm/6-2017q2/gcc-arm-none-eabi-6-2017-q2-update-linux.tar.bz2 /

RUN tar jxf gcc-arm-none-eabi-6-2017-q2-update-linux.tar.bz2 && rm gcc-arm-none-eabi-6-2017-q2-update-linux.tar.bz2

RUN pip install --upgrade pip

RUN pip install mbed-cli && mbed import https://github.com/ARMmbed/mbed-os-example-blinky

## ---- user: developer ----
ENV USER_NAME=developer
ENV USER_ID=1000
ENV GROUP_ID=1000
ENV HOME=/home/${USER_NAME}
ENV PATH /gcc-arm-none-eabi-6-2017-q2-update/bin:$PATH

RUN export DISPLAY=${DISPLAY} && \
    useradd ${USER_NAME} && \
    export uid=${USER_ID} gid=${GROUP_ID} && \
    mkdir -p ${HOME} && \
    mkdir -p /etc/sudoers.d && \
    echo "${USER_NAME}:x:${USER_ID}:${GROUP_ID}:${USER_NAME},,,:${HOME}:/bin/bash" >> /etc/passwd && \
    echo "${USER_NAME}:x:${USER_ID}:" >> /etc/group && \
    echo "${USER_NAME} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${USER_NAME} && \
    chmod 0440 /etc/sudoers.d/${USER_NAME} && \
    chown ${USER_NAME}:${USER_NAME} -R ${HOME}
USER ${USER_NAME}
WORKDIR ${HOME}
