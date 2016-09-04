#!/usr/bin/python
import subprocess
from SimpleCV import Color, Image
import time
img = Image("/dev/shm/lastsnap.jpg")
img.save("/dev/shm/p1.png")
#img = img.binarize()
#macchie = img.findBlobs()
#img.save("p2.png")
#print "Areas: ", macchie.area()
#print "Angles: ", macchie.angle()
#print "Centers: ", macchie.coordinates()
#colore = (0,255,0)

blue_distance = img.hueDistance(Color.GREEN)
#.invert()
#blue_distance = img.colorDistance(Color.GREEN);
#.invert()

blobs = blue_distance.findBlobs()

blobs.draw(color=Color.PUCE, width=2)
#blue_distance.show()
blue_distance.save("/dev/shm/p3.png")

img.addDrawingLayer(blue_distance.dl())

img.save("/dev/shm/p4.png")
