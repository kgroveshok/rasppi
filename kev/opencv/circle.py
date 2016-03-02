#!/usr/bin/python
import subprocess
from SimpleCV import Color, Image
import time
img = Image("/dev/shm/lastsnap.jpg")
img.save("p1.png")

circles =img.findCircle(canny=200,thresh=250,distance=15)
circles = circles.sortArea()
#circles.draw(width=4)
#circles[0].draw(color=Color.RED, width=4)
#img_with_circles = img.applyLayers()
#edges_in_image = img.edges(t2=200)

img.save("p2.png")

#final =img.sideBySide(edges_in_image.sideBySide(img_with_circles)).scale(0.5)

#img.save("p3.png")
