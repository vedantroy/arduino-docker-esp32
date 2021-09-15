# Dockerized Arduino IDE for ESP32

This is a Dockerfile for running the Arduino IDE in Linux with the [ESP32 core](https://github.com/espressif/arduino-esp32) installed as well.

I was trying to compile / run Arduino programs for ESP32 on Linux (Ubuntu), but I kept on running into issues. 

I also tried using the Arduino CLI, but that was broken for the ESP32:
- https://github.com/arduino/arduino-cli/issues/1450#issuecomment-918364346

This Dockerfile makes it easy to run the Arduino IDE & upload programs to the ESP32.

Build the image with:
```
   docker build . -t esp32:latest
```

And run it with `./run.sh`

Your board needs to be plugged in.

## Further Instructions
Once the IDE is launched:
- Select "Tools > Board > ESP32 Dev Module" 
- Select the right port (/dev/tty/USB0) in "Tools > Port"
- According to UMass CICS256, you should change the upload rate to 460800
  - Not sure if this is only for the board provided in CICS256

