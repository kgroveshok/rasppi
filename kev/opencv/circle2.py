#!/usr/bin/python
import subprocess
from SimpleCV import Color, Image
import time

img = Image("/dev/shm/lastsnap.jpg")
img.save("p1.png")
cerchi = img.findCircle(canny=250,thresh=200,distance=11)
#cerchi.draw(color=Color.BLACK, width=4)
cerchi = cerchi.sortArea()
cerchi[0].draw(color=Color.RED, width=4)
img_with_circles = img.applyLayers()
img_with_circles.save("/dev/shm/p4.png")
