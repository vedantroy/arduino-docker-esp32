#! /bin/sh
# You will need to have your board plugged in
docker run -it --rm --network=host -e DISPLAY=$DISPLAY --device /dev/ttyUSB0:/dev/ttyUSB0 -v $HOME/.Xauthority:/home/developer/.Xauthority esp32:latest


