# This is an amalgation of
# https://github.com/denlabo/dockerfile-arduino-ide-ble-nano/blob/master/Dockerfile
# https://github.com/tombenke/darduino
FROM ubuntu:20.04

ENV HOME /home/developer
WORKDIR /home/developer

# Replace with your UID/GID (1000 is probably correct though)
# id -u <username>
# id -g <username>
# https://kb.iu.edu/d/adwf
RUN export uid=1000 gid=1000 && \
    mkdir -p /home/developer && \
    mkdir -p /etc/sudoers.d && \
    echo "developer:x:${uid}:${gid}:Developer,,,:/home/developer:/bin/bash" >> /etc/passwd && \
    echo "developer:x:${uid}:" >> /etc/group && \
    echo "developer ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/developer && \
    chmod 0440 /etc/sudoers.d/developer && \
    chown ${uid}:${gid} -R /home/developer && \
    apt-get update \
    # tools to download / install arduino IDE
	&& apt-get install -y sudo wget xz-utils \
    && sudo apt-get clean

# Add developer user to the dialout group to be ale to write the serial USB device
RUN sed "s/^dialout.*/&developer/" /etc/group -i \
    && sed "s/^root.*/&developer/" /etc/group -i

ENV ARDUINO_IDE_VERSION 1.8.6

RUN wget https://downloads.arduino.cc/arduino-${ARDUINO_IDE_VERSION}-linux64.tar.xz && \
	tar Jxf arduino-${ARDUINO_IDE_VERSION}-linux64.tar.xz -C ~/ && rm arduino-${ARDUINO_IDE_VERSION}-linux64.tar.xz && \
	chmod u+x ~/arduino-${ARDUINO_IDE_VERSION}/arduino && \
	mkdir ~/.bin/ && ln -s ~/arduino-${ARDUINO_IDE_VERSION}/arduino ~/.bin/arduino && \
	mkdir ~/Arduino/

# Arduino IDE runtime libs
RUN sudo apt-get install -y \
                # Prevents
                # https://github.com/arduino/Arduino/issues/8119
                # (Cannot load com.sun.java [...])
                # This error was supposedly fixed in a PR, but it was still happening to me...
                libgtk2.0-0 \
                # Prevents
                # java.lang.UnsatisfiedLinkError: /usr/local/share/arduino-1.8.6/java/lib/amd64/libawt_xawt.so:
                # libXtst.so.6: cannot open shared object file: No such file or directory
                libxtst-dev \
                # Prevents: Gtk-Message: Failed to load module "canberra-gtk-module"
                # (Not super important, the error isn't fatal)
                libcanberra-gtk-module

ENV DISPLAY :1.0

# Install Arduino-ESP32 (build from source)
# (https://docs.espressif.com/projects/arduino-esp32/en/latest/installing.html)
# split the command into several RUN steps so dev workflow is faster when editing the Dockerfile
RUN sudo apt-get install -y git
# run this command before the rest of the setup since it takes a while
RUN sudo mkdir -p ~/Arduino/hardware/espressif \
        && cd ~/Arduino/hardware/espressif \
        && git clone --quiet https://github.com/espressif/arduino-esp32.git esp32 \
        && cd esp32 \
        && git submodule update --init --recursive

RUN sudo apt-get -y install python3
# same deal here, run this command before installing other deps
RUN cd ~/Arduino/hardware/espressif/esp32/tools && python3 get.py
# python-is-python3 is important
# https://forum.arduino.cc/t/solved-arduino-ide-on-linux-mint-20-no-serial-module/678187/6
# https://github.com/espressif/esptool/issues/528
RUN sudo apt-get -y install python3-pip python-is-python3
RUN sudo apt-get clean && rm -rf /var/lib/apt/lists/*
RUN pip3 install pyserial

# Install Adafruit NeoPixel library
RUN mkdir ~/Arduino/libraries
RUN git clone https://github.com/adafruit/Adafruit_NeoPixel.git ~/Arduino/libraries/Adafruit_NeoPixel

# Install more Adafruit libraries
RUN git clone https://github.com/adafruit/Adafruit_SSD1306.git ~/Arduino/libraries/Adafruit_SSD1306
RUN git clone https://github.com/adafruit/Adafruit-GFX-Library.git ~/Arduino/libraries/Adafruit_GFX
RUN git clone https://github.com/adafruit/Adafruit_BusIO.git ~/Arduino/libraries/Adafruit_BusIO

# To install more complicated libs
COPY ./WebServer /home/developer/Arduino/libraries/WebServer/

USER developer

# Launch the IDE
CMD ["/home/developer/.bin/arduino"]
