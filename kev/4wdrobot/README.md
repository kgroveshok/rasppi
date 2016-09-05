4WD Robot
---------


Robot Hardware:

#  4init 4wd bot base - add link
#  sharp ir sensor - link 
#  ultrasonic sensor - link
#  pan/tilt arm (2 x servo) -link 
#  usb webcam mounted on continuois servo (becase lacking a 180deg servo)
#  piconzero controller - link
#    motors connected h-bridge
#    ultrasonic on deadicated connection
#    ir on input pin 3
#    wheel rotation counters on pins 0 and 1
#    arm pan/tilt on output 0 and 1
#    webcam server on output 2
#
# software:
#  python
#  opencv/simplecv
#  motion (with single image and video streaming)
#  piconzero requirements for i2c
#  lighttpd for access to motion/opencv image processing

add from command history


