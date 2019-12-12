#!/bin/sh


# https://pimylifeup.com/raspberry-pi-playstation-controllers/

# https://core-electronics.com.au/tutorials/using-usb-and-bluetooth-controllers-with-python.html
# sudo pip install evdev
# python /usr/local/lib/python2.7/dist-packages/evdev/evtest.py

sudo /root/sixpair/sixpair


#sudo bluetoothctl <<EOF
#trust 04:76:6E:6D:6C:FA
#trust 00:26:5C:82:3E:C7
#EOF


service bluetooth start
sudo sixad --start &

