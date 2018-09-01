FROM debian:9

RUN apt-get update && apt-get install -y gpg wget xz-utils git \
    # arduino build deps
    make gcc ant openjdk-8-jdk unzip lbzip2

RUN mkdir -p /usr/src/arduino && \
    wget https://github.com/arduino/Arduino/releases/download/1.8.5/Arduino-1.8.5.tar.xz && \
    wget https://github.com/arduino/Arduino/releases/download/1.8.5/Arduino-1.8.5.tar.xz.asc && \
    wget https://downloads.arduino.cc/arduino_sources_gpg_pubkey.txt && \
    \
    gpg --import arduino_sources_gpg_pubkey.txt && \
    gpg --list-keys | grep "326567C1C6B288DF32CB061A95FA6F43E21188C4" && \
    gpg --verify Arduino-1.8.5.tar.xz.asc && \
    \
    mkdir -p /usr/src/arduino && \
    tar --strip-components=1 -C /usr/src/arduino -xf Arduino-1.8.5.tar.xz && \
    cd /usr/src/arduino/build && \
    # echo to answer a prompt with newline
    echo | ant dist && \
    mkdir -p /usr/local/arduino && \
    tar --strip-components=1 -C /usr/local/arduino -xf ./linux/arduino-1.8.5-linux64.tar.xz && \
    rm -rf /usr/src/arduino /root/

ENV ARDUINO_PATH=/usr/local/arduino

WORKDIR /root/Arduino
RUN mkdir -p hardware/keyboardio
RUN git clone --recursive https://github.com/keyboardio/Arduino-Boards.git hardware/keyboardio/avr
RUN cd hardware/keyboardio/avr && git checkout a99d0483468dc8980318d2da45551bbbbc29c0fa

RUN git clone https://github.com/keyboardio/Model01-Firmware.git && \
    cd Model01-Firmware && \
    git checkout 29c80e38c82ca17d9fe7fa7965e0c4ebcb4f6771

WORKDIR /root/Arduino/Model01-Firmware

RUN apt-get install -y udev
