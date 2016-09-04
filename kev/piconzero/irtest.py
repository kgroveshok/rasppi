#! /usr/bin/env python

# GNU GPL V3
# Test code for 4tronix Picon Zero

import piconzero as pz, time

lastPix = 0
numpixels = 8

pz.init()
pz.setInputConfig(3, 1)     # set input 0 to Analog
try:
    while True:
        ana0 = pz.readInput(3)
        print "a : ", ana0
        time.sleep(0.1)
except KeyboardInterrupt:
    print
finally:
    pz.cleanup()

