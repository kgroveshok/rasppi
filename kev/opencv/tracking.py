#!/usr/bin/python
import subprocess
from SimpleCV import Color, Image
import time

#js = JpegStreamer(port=8090) 

while(1):

    img = Image("/dev/shm/lastsnap.jpg")


    object = img.hueDistance(Color.BLUE)
    object.save("/dev/shm/p3.png")

    #blobs = blue_distance.findBlobs()

    #object.draw(color=Color.PUCE, width=2)
    #blue_distance.show()
    #blue_distance.save("/dev/shm/p3.png")

    corners=img.findCorners()

    print object.meanColor()

    num_corners = len(corners)
    print "Corners Found:" + str(num_corners)

    corners.draw()

    img.addDrawingLayer(object.dl())


    # circle tracking

    #dist = img.colorDistance(Color.BLACK).dilate(2)
    #segmented = dist.stretch(200,255)

    blobs = img.findBlobs()
    if blobs:
            circles = blobs.filter([b.isCircle(0.2) for b in blobs])
            if circles:
                img.drawCircle((circles[-1].x, circles[-1].y), circles[-1].radius(),Color.BLUE,3)




    img.save("/dev/shm/p4.png")

    #img.save(js.framebuffer)

    time.sleep(2)
