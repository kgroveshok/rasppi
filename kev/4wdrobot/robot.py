#!/usr/bin/python
# Based on Picon Zero Motor Test
#
# robot hardware:
#  4init 4wd bot base
#  sharp ir sensor
#  ultrasonic sensor
#  pan/tilt arm (2 x servo)
#  usb webcam mounted on continuois servo (becase lacking a 180deg servo)
#  piconzero controller
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
# 

import piconzero as pz, time

import subprocess
from SimpleCV import Color, Image
import time
import cv2
import sys
import tty
import termios
import hcsr04
import select
import PIL
import zbar
import curses
from shutil import copyfile
import random
from bisect import bisect


stdscr = curses.initscr()
curses.noecho()
curses.cbreak()
stdscr.keypad(1)
#nodelay(1)
hcsr04.init()


def readSensors():
        ir = pz.readInput(irSen)
        distance = int(hcsr04.getDistance())

        #leftRev=pz.readInput(leftCounter)
        #if leftRev <> leftState:
        #     leftTotal = leftTotal + 1

        #rightRev=pz.readInput(rightCounter)

        #if rightRev <> rightState:
        #     rightTotal = rightTotal + 1

        #leftState=leftRev
        #rightState=rightRev

        volts=min(0.1,ir*0.0029296875 )  #min(1,ir*0.006);  # // value from sensor * (5/1024) - if running 3.3.volts then change 5 to 3.3

        actdist= (65*pow(volts, -1.10));  #        // worked out from graph 65 = theretical distance / (1/Volts)S - luckylarry.co.uk
        return (ir, distance, volts, actdist)

def asciiSensor( maxVal, reading ):
    # convert a sensor reading into an ASCII form for easy render on terminal
    # TODO generate an image depth map version too as opencv now includes view of images via web server

    # algo source https://stevendkay.wordpress.com/2009/09/08/generating-ascii-art-from-photographs-in-python/
    mval=min(maxVal, reading)

    greyscale = [
                " ",
                " ",
                ".,-",
                "_ivc=!/|\\~",
                "gjez2]/(YL)t[+T7Vf",
                "mdK4ZGbNDXY5P*Q",
                "W8KMA",
                "#%$"
                ]


    zonebounds=[36,72,108,144,180,216,252]
   
    # rescale the distance to fixed range

    NewValue = (((mval ) * 255) / maxVal) 

 

    lum=255-NewValue
    row=bisect(zonebounds,lum)
    possibles=greyscale[row]
    return possibles[random.randint(0,len(possibles)-1)]


def pixelSensor( maxVal, reading ):
    # convert a sensor reading into an ASCII form for easy render on terminal
    # TODO generate an image depth map version too as opencv now includes view of images via web server

    # algo source https://stevendkay.wordpress.com/2009/09/08/generating-ascii-art-from-photographs-in-python/
    mval=min(maxVal, reading)



    NewValue = (((mval ) * 255) / maxVal) 

    return 255-NewValue

def readchar():
    fd = sys.stdin.fileno()
    old_settings = termios.tcgetattr(fd)
    try:
        tty.setraw(sys.stdin.fileno())
        ch = sys.stdin.read(1)
    finally:
        termios.tcsetattr(fd, termios.TCSADRAIN, old_settings)
    if ch == '0x03':
        raise KeyboardInterrupt
    return ch

def readkey(getchar_fn=None):
    getchar = getchar_fn or readchar
    c1 = getchar()
    if ord(c1) != 0x1b:
        return c1
    c2 = getchar()
    if ord(c2) != 0x5b:
        return c1
    c3 = getchar()
    return chr(0x10 + ord(c3) - 65)  # 16=Up, 17=Down, 18=Right, 19=Left arrows

def GetChar(Block=True):
  if Block or select.select([sys.stdin], [], [], 0) == ([sys.stdin], [], []):
    return sys.stdin.read(1)
  return '0'

# window setup

helpWin = curses.newwin(5, 80, 0, 0)
sensorWin = curses.newwin(4,80, 5, 0)
statusWin = curses.newwin(7,80, 9, 0)
scanWin = curses.newwin(30, 90, 15, 0)

helpWin.border()
sensorWin.border()
statusWin.border()
scanWin.border()


# define motor speeds

sensorLast=0
speed = 60
turnSpeed=100
neckSpeed = 60

# Define which pins are the servos and sensors
pan = 0
tilt = 1
cam = 2

rightCounter=0
leftCounter=1
irSen=3

# TODO add line following
#leftLine
#rightLine

# current sensor state
leftState=0
rightState=0

# running total of change of state
leftTotal=0
rightTotal=0

# init all hardware

pz.init()

# Set output mode to Servo
pz.setOutputConfig(pan, 2)
pz.setOutputConfig(tilt, 2)
pz.setOutputConfig(cam, 2)

pz.setInputConfig(irSen, 1)     # set input 0 to Analog

pz.setInputConfig(leftCounter, 0)     # set input 0 to Analog
pz.setInputConfig(rightCounter, 0)     # set input 0 to Analog

# Centre positions for all servos
panVal = 90
tiltVal = 90
camVal = 90

pz.setOutput (pan, panVal)
pz.setOutput (tilt, tiltVal)
pz.setOutput (cam, camVal)

# position for 'head down' while moving forward for collis detection
fwdPan=90
fwdTilt=75

# value to monitor for sudden distance change and to stop on significant change
fwdSafe=0

distance=0
ir=0

helpWin.addstr(1,1, "Tests the motors by using the arrow keys to control. num keys. 5 to stop. IJLM. K=stop")
helpWin.addstr(2, 1, "Use , or < to slow down. Use . or > to speed up. V to distance scan")
helpWin.addstr(3,1, "WADZ. S = centre. opencv scan=E. R=save webcam")
helpWin.refresh()

# main loop

try:
    while True:
        #keyp = readkey()
        #keyp = readchar()
        keyp = GetChar(False)
        if keyp == '2' or keyp == 'm' or ord(keyp) == 16:
            pz.forward(speed)
            #statusWin.clear()
            statusWin.addstr(1,1, 'Reverse '+ str(speed)+"    ")
        elif keyp == 'r':
            prefix=str(time.time())
            copyfile("/dev/shm/lastsnap.jpg","/home/pi/"+prefix+"_lastsnap.jpg")
            copyfile("/dev/shm/p3.png","/home/pi/"+prefix+"_p3.png")
            copyfile("/dev/shm/p4.png","/home/pi/"+prefix+"_p4.png")
            copyfile("/dev/shm/sonar.png","/home/pi/"+prefix+"_sonar.png")
            copyfile("/dev/shm/pdenos.jpg","/home/pi/"+prefix+"_pdenos.jpg")
            copyfile("/dev/shm/p5.jpg","/home/pi/"+prefix+"_p5.jpg")
            statusWin.addstr(1,1, 'Saved webcam and opencv images to prefix '+prefix)
        elif keyp == 'e':


            img = Image("/dev/shm/lastsnap.jpg")


            object = img.hueDistance(Color.BLUE)
            object.save("/dev/shm/p3.png")
            object.save("/dev/shm/p3.jpg") # for shape denoise handling

            #blobs = blue_distance.findBlobs()

            #object.draw(color=Color.PUCE, width=2)
            #blue_distance.show()
            #blue_distance.save("/dev/shm/p3.png")

            corners=img.findCorners()

            statusWin.clear()
            statusWin.addstr( 1, 1,  str(object.meanColor()))


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
            
            
            blobs.draw(color=Color.RED, width=2)


            num_corners = len(corners)
            num_blobs = len(blobs)
            statusWin.addstr(2,1, "Corners Found:" + str(num_corners))
            statusWin.addstr(3,1, "Blobs Found:" + str(num_blobs))

            img.save("/dev/shm/p4.png")
            img.save("/dev/shm/p4b.jpg")

            img2 = cv2.imread('/dev/shm/lastsnap.jpg')
            grey = cv2.imread('/dev/shm/p3.jpg',0)
            #grey = cv2.imread('/dev/shm/lastsnap.jpg',0)

            #worked are removing noise but took wayyyyyy too long
            #denos=cv2.fastNlMeansDenoising(grey, None, 10)

            # detection against a greyscale image. 
            # change thresholds against different backgrounds
            #ret, thresh = cv2.threshold( denos,80,80, 1)
            ret, thresh = cv2.threshold( grey,80,80,1)
            contours, h = cv2.findContours( thresh, 1,2 )

            # http://stackoverflow.com/questions/11424002/how-to-detect-simple-geometric-shapes-using-opencv

            cpent=0
            ctri=0
            csqr=0
            chc=0
            ccir=0
            for cnt in contours:
                approx = cv2.approxPolyDP(cnt,0.01*cv2.arcLength(cnt,True),True)
                #print len(approx)
                statusWin.addstr(3,20, "Contours Found:" + str(len(approx)))
                if len(approx)==5:
                    #print "pentagon"
                    cpent=cpent+1
                    #cv2.drawContours(img2,[cnt],0,255,-1)
                elif len(approx)==3:
                    #print "triangle"
                    ctri=ctri+1
                    cv2.drawContours(img2,[cnt],0,Color.RED,-1)
                elif len(approx)==4:
                    #print "square"
                    csqr=csqr+1
                    cv2.drawContours(img2,[cnt],0,Color.BLUE,-1)
                elif len(approx) == 9:
                    #print "half-circle"
                    chc=chc+1
                    cv2.drawContours(img2,[cnt],0,Color.GREEN,-1)
                elif len(approx) > 15:
                    #print "circle"
                    ccir=ccir+1
                    #cv2.drawContours(img2,[cnt],0,Color.PUCE,-1)

                statusWin.addstr(3,40, "pent=" + str(cpent)+" R.tri="+str(ctri)+" B.sqr="+str(csqr)+" G.hc="+str(chc)+" cir="+str(ccir))


            #cv2.imwrite("/dev/shm/pdenos.jpg",denos)
            cv2.imwrite("/dev/shm/pdenos.jpg",grey)
            cv2.imwrite("/dev/shm/p5.jpg",img2)


            # using the greyscale version from the shape detector detect bar codes

            scanner = zbar.ImageScanner()
            scanner.parse_config('enable')
            pil = PIL.Image.fromarray(grey)
            width, height = pil.size
            raw = pil.tostring()

            image = zbar.Image(width, height, 'Y800', raw)
            scanner.scan(image)

            fstr=''
            for symbol in image:
               fstr = fstr + ' decoded' + symbol.type + ' symbol '+ symbol.data

            statusWin.addstr(4,1, "barcode "+fstr)
               


            #img.save(js.framebuffer)


        elif keyp == 'v':
             pz.stop()
             pts = []
             row=2

             # create image
            
             #sonarImg=PIL.Image.new('RGB',(512,150),(255,255,255))
             sonarImg=PIL.Image.new('RGB',(250,150),(255,255,255))
             #irImg=Image.new('RGB',(1024,1024))
              

             scanWin.addstr(1,1,"Distance Map"          )
             scanWin.addstr(2,1, "Sonar")
             for span in range( 39, 75, 3 ):
               #irLine=""
               sonLine=""

               for stilt in range( 150, 30, -3 ):
                  pz.setOutput (pan, span)
                  pz.setOutput (tilt, stilt)
                  time.sleep( 0.1)
                  ir, distance, volts, actdist = readSensors()
                  #ir = pz.readInput(irSen)
                  #distance = int(hcsr04.getDistance())
                  #print "At pan,tilt: ",span,",",stilt,": ir Distance:", ir, " sonic distance: ", distance

                  #volts=min(1,ir*0.0048828125);  # // value from sensor * (5/1024) - if running 3.3.volts then change 5 to 3.3
                  #volts=min(1,ir*0.002929688);  # // value from sensor * (5/1024) - if running 3.3.volts then change 5 to 3.3

                  #actdist=65*pow(volts, -1.10);  #        // worked out from graph 65 = theretical distance / (1/Volts)S - luckylarry.co.uk

                  #print "ir act distance: ",actdist

	              # TODO: Save values and pos so build map

                  # rescale reading to ascii value

                  #irLine = irLine + asciiSensor( 400, 400-min(400,ir) ) 
                  #irImg.putpixel( ( stilt, span), pixelSensor( 400, 400-min(400,ir) ) ) 
                  #px=pixelSensor( 400, 400-min(400,ir) )
                  #px2=(px,px,0)
                  #sonarImg.putpixel( ( stilt+200, span), px2) 
                  #sonarImg.putpixel( ( stilt+200, span+1), px2) 
                  #sonarImg.putpixel( ( stilt+200, span+2), px2) 


                  #sonarImg.putpixel( ( stilt+201, span), px2) 
                  #sonarImg.putpixel( ( stilt+201, span+1), px2) 
                  #sonarImg.putpixel( ( stilt+201, span+2), px2) 

                  # sonarImg.putpixel( ( stilt+202, span), px2) 
                  #sonarImg.putpixel( ( stilt+202, span+1), px2) 
                  #sonarImg.putpixel( ( stilt+202, span+2), px2) 
                  #sonarImg.putpixel( ( stilt+200, span), (pixelSensor( 400, 400-min(400,ir) ),0,0) ) 

                  sonLine = sonLine + asciiSensor(80, distance )
                  px=pixelSensor(80, distance )
                  px2=(px,px,0)
                  #sonarImg.putpixel( (stilt, span), (pixelSensor(80, distance ),0,0))

                  sonarImg.putpixel( (stilt, span), px2)
                  sonarImg.putpixel( (stilt, span+1), px2)
                  sonarImg.putpixel( (stilt, span+2), px2)

                  sonarImg.putpixel( (stilt+1, span), px2)
                  sonarImg.putpixel( (stilt+1, span+1), px2)
                  sonarImg.putpixel( (stilt+1, span+2), px2)

                  sonarImg.putpixel( (stilt+2, span), px2)
                  sonarImg.putpixel( (stilt+2, span+1), px2)
                  sonarImg.putpixel( (stilt+2, span+2), px2)

               row=row+1
               #scanWin.addstr(row,1, sonLine+ " | "+ str(irLine))
               scanWin.addstr(row,1, sonLine)
               scanWin.refresh()

             pz.setOutput (pan, panVal)
             pz.setOutput (tilt, tiltVal)
             #irImg.save('/dev/shm/ir.png')
             sonarImg.save('/dev/shm/sonar.png')
        elif keyp == '8' or keyp == 'i' or ord(keyp) == 17:
            panVal = fwdPan
            tiltVal = fwdTilt
            pz.setOutput (pan, panVal)
            pz.setOutput (tilt, tiltVal)

            pz.stop()
            # get a sample for safe value

            fwdSafe=0
            #for c in range(0,20):
            #    fwdSafe = max(fwdSafe, int(hcsr04.getDistance()))
            #    time.sleep(0.1)
            pz.reverse(speed)
            #statusWin.clear()
            statusWin.addstr(1,1,'Forward '+ str(speed)+"     ")

 
            

        elif keyp == '4' or keyp == 'j' or ord(keyp) == 18:
            pz.spinRight(turnSpeed)
            #statusWin.clear()
            statusWin.addstr(1,1, 'Spin Right '+ str(speed)+"    ")
        elif keyp == '6' or keyp == 'l' or ord(keyp) == 19:
            pz.spinLeft(turnSpeed)
            #statusWin.clear()
            statusWin.addstr(1,1, 'Spin Left '+ str(speed)+"     ")
        elif keyp == '.' or keyp == '>':
            speed = min(100, speed+10)
            #statusWin.clear()
            statusWin.addstr(1,1, 'Speed+ '+ str(speed)+"     ")
        elif keyp == ',' or keyp == '<':
            speed = max (0, speed-10)
            #statusWin.clear()
            statusWin.addstr(1,1, 'Speed- '+ str(speed)+"    ")
        elif keyp == 'w':
            panVal = max (0, panVal - 5)
            #statusWin.clear()
            statusWin.addstr(1,1, 'Up ' + str(panVal)+"    ")
            pz.setOutput (pan, panVal)
            pz.setOutput (tilt, tiltVal)
        elif keyp == 'z':
            panVal = min (180, panVal + 5)
            #statusWin.clear()
            statusWin.addstr(1,1, 'Down '+ str(panVal)+"   ")
            pz.setOutput (pan, panVal)
            pz.setOutput (tilt, tiltVal)
        elif keyp == 'd' :
            tiltVal = max (0, tiltVal - 5)
            #statusWin.clear()
            statusWin.addstr(1,1,'Right '+ str(tiltVal)+"      ")
            pz.setOutput (pan, panVal)
            pz.setOutput (tilt, tiltVal)
        elif keyp == 'a' :
            tiltVal = min (180, tiltVal + 5)
            #statusWin.clear()
            statusWin.addstr(1,1, 'Left '+ str(tiltVal)+"     ")
            pz.setOutput (pan, panVal)
            pz.setOutput (tilt, tiltVal)
        elif keyp == 'f':
            #print 'Cam', camVal
            pz.setOutput (cam, 100)
            time.sleep(0.1)
            pz.setOutput( cam, 90)
        elif keyp == 'g':
            pz.setOutput (cam, 80)
            time.sleep(0.1)
            pz.setOutput( cam, 90)
        elif keyp =='q':
                curses.nocbreak(); stdscr.keypad(0); curses.echo()
                curses.endwin()
                abort()
        elif keyp == 's':
            panVal = 90
            tiltVal = 75
            #print 'Centre'
            pz.setOutput (pan, panVal)
            pz.setOutput (tilt, tiltVal)
        elif ord(keyp) == 3:
            break
        elif keyp == '5' or keyp == 'k':
            pz.stop()
            statusWin.addstr(1,1,'Stop')
        elif ord(keyp) == 3:
            break


        statusWin.refresh()

        if sensorLast < time.time(): 
          ir, distance, volts, actdist = readSensors()
          t=int(time.time())
          sensorLast=t+1

          #    ir = pz.readInput(irSen)
          #    distance = int(hcsr04.getDistance())
        

        leftRev=pz.readInput(leftCounter)
        if leftRev <> leftState:
             leftTotal = leftTotal + 1

        rightRev=pz.readInput(rightCounter)

        if rightRev <> rightState:
             rightTotal = rightTotal + 1

        leftState=leftRev
        rightState=rightRev

        #volts=min(0.1,ir*0.0029296875 )  #min(1,ir*0.006);  # // value from sensor * (5/1024) - if running 3.3.volts then change 5 to 3.3

        #actdist= (65*pow(volts, -1.10));  #        // worked out from graph 65 = theretical distance / (1/Volts)S - luckylarry.co.uk
        #sensorWin.clear()
        sensorWin.addstr(1,1, "Sonar Distance: "+ str(distance)+"    ")
        sensorWin.addstr(1,30, " Safe: "+ str(fwdSafe)+"        " )
        sensorWin.addstr(1,40, " iR Distance: "+ str(ir)+"   Actual: "+str(actdist)+"    " )
        sensorWin.addstr(2,1, "Left Counter: "+ str(leftTotal)+"        " )
        sensorWin.addstr(2,30, "Right Counter: "+ str(rightTotal)+"        " )


        sensorWin.refresh()

        # coli detection

        if( distance < fwdSafe ):
            #pz.stop()
            # clear value so it does not prevent any turning to avoid!
            #fwdSafe=0
            #statusWin.clear()
            statusWin.addstr(2,1, "Stopping.... Something too close      ")
            statusWin.refresh()
      
except KeyboardInterrupt:
    print

finally:
    hcsr04.cleanup()

    pz.cleanup()
# Based on Picon Zero Motor Test
#
# robot hardware:
#  4init 4wd bot base
#  sharp ir sensor
#  ultrasonic sensor
#  pan/tilt arm (2 x servo)
#  usb webcam mounted on continuois servo (becase lacking a 180deg servo)
#  piconzero controller
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
# 

import piconzero as pz, time

import subprocess
from SimpleCV import Color, Image
import time
import cv2
import sys
import tty
import termios
import hcsr04
import select
import PIL
import zbar
import curses
from shutil import copyfile
import random
from bisect import bisect


stdscr = curses.initscr()
curses.noecho()
curses.cbreak()
stdscr.keypad(1)
#nodelay(1)
hcsr04.init()


def readSensors():
        ir = pz.readInput(irSen)
        distance = int(hcsr04.getDistance())

        #leftRev=pz.readInput(leftCounter)
        #if leftRev <> leftState:
        #     leftTotal = leftTotal + 1

        #rightRev=pz.readInput(rightCounter)

        #if rightRev <> rightState:
        #     rightTotal = rightTotal + 1

        #leftState=leftRev
        #rightState=rightRev

        volts=min(0.1,ir*0.0029296875 )  #min(1,ir*0.006);  # // value from sensor * (5/1024) - if running 3.3.volts then change 5 to 3.3

        actdist= (65*pow(volts, -1.10));  #        // worked out from graph 65 = theretical distance / (1/Volts)S - luckylarry.co.uk
        return (ir, distance, volts, actdist)

def asciiSensor( maxVal, reading ):
    # convert a sensor reading into an ASCII form for easy render on terminal
    # TODO generate an image depth map version too as opencv now includes view of images via web server

    # algo source https://stevendkay.wordpress.com/2009/09/08/generating-ascii-art-from-photographs-in-python/
    mval=min(maxVal, reading)

    greyscale = [
                " ",
                " ",
                ".,-",
                "_ivc=!/|\\~",
                "gjez2]/(YL)t[+T7Vf",
                "mdK4ZGbNDXY5P*Q",
                "W8KMA",
                "#%$"
                ]


    zonebounds=[36,72,108,144,180,216,252]
   
    # rescale the distance to fixed range

    NewValue = (((mval ) * 255) / maxVal) 

 

    lum=255-NewValue
    row=bisect(zonebounds,lum)
    possibles=greyscale[row]
    return possibles[random.randint(0,len(possibles)-1)]


def pixelSensor( maxVal, reading ):
    # convert a sensor reading into an ASCII form for easy render on terminal
    # TODO generate an image depth map version too as opencv now includes view of images via web server

    # algo source https://stevendkay.wordpress.com/2009/09/08/generating-ascii-art-from-photographs-in-python/
    mval=min(maxVal, reading)



    NewValue = (((mval ) * 255) / maxVal) 

    return 255-NewValue

def readchar():
    fd = sys.stdin.fileno()
    old_settings = termios.tcgetattr(fd)
    try:
        tty.setraw(sys.stdin.fileno())
        ch = sys.stdin.read(1)
    finally:
        termios.tcsetattr(fd, termios.TCSADRAIN, old_settings)
    if ch == '0x03':
        raise KeyboardInterrupt
    return ch

def readkey(getchar_fn=None):
    getchar = getchar_fn or readchar
    c1 = getchar()
    if ord(c1) != 0x1b:
        return c1
    c2 = getchar()
    if ord(c2) != 0x5b:
        return c1
    c3 = getchar()
    return chr(0x10 + ord(c3) - 65)  # 16=Up, 17=Down, 18=Right, 19=Left arrows

def GetChar(Block=True):
  if Block or select.select([sys.stdin], [], [], 0) == ([sys.stdin], [], []):
    return sys.stdin.read(1)
  return '0'

# window setup

helpWin = curses.newwin(5, 80, 0, 0)
sensorWin = curses.newwin(4,80, 5, 0)
statusWin = curses.newwin(7,80, 9, 0)
scanWin = curses.newwin(30, 90, 15, 0)

helpWin.border()
sensorWin.border()
statusWin.border()
scanWin.border()


# define motor speeds

sensorLast=0
speed = 60
turnSpeed=100
neckSpeed = 60

# Define which pins are the servos and sensors
pan = 0
tilt = 1
cam = 2

rightCounter=0
leftCounter=1
irSen=3



# current sensor state
leftState=0
rightState=0

# running total of change of state
leftTotal=0
rightTotal=0

# init all hardware

pz.init()

# Set output mode to Servo
pz.setOutputConfig(pan, 2)
pz.setOutputConfig(tilt, 2)
pz.setOutputConfig(cam, 2)

pz.setInputConfig(irSen, 1)     # set input 0 to Analog

pz.setInputConfig(leftCounter, 0)     # set input 0 to Analog
pz.setInputConfig(rightCounter, 0)     # set input 0 to Analog

# Centre positions for all servos
panVal = 90
tiltVal = 90
camVal = 90

pz.setOutput (pan, panVal)
pz.setOutput (tilt, tiltVal)
pz.setOutput (cam, camVal)

# position for 'head down' while moving forward for collis detection
fwdPan=90
fwdTilt=75

# value to monitor for sudden distance change and to stop on significant change
fwdSafe=0

distance=0
ir=0

helpWin.addstr(1,1, "Tests the motors by using the arrow keys to control. num keys. 5 to stop. IJLM. K=stop")
helpWin.addstr(2, 1, "Use , or < to slow down. Use . or > to speed up. V to distance scan")
helpWin.addstr(3,1, "Move cam. F and G. Neck. WADZ. S = centre. opencv scan=E. R=save webcam")
helpWin.refresh()

# main loop

try:
    while True:
        #keyp = readkey()
        #keyp = readchar()
        keyp = GetChar(False)
        if keyp == '2' or keyp == 'm' or ord(keyp) == 16:
            pz.forward(speed)
            #statusWin.clear()
            statusWin.addstr(1,1, 'Reverse '+ str(speed)+"    ")
        elif keyp == 'r':
            prefix=str(time.time())
            copyfile("/dev/shm/lastsnap.jpg","/home/pi/"+prefix+"_lastsnap.jpg")
            copyfile("/dev/shm/p3.png","/home/pi/"+prefix+"_p3.png")
            copyfile("/dev/shm/p4.png","/home/pi/"+prefix+"_p4.png")
            copyfile("/dev/shm/sonar.png","/home/pi/"+prefix+"_sonar.png")
            copyfile("/dev/shm/pdenos.jpg","/home/pi/"+prefix+"_pdenos.jpg")
            copyfile("/dev/shm/p5.jpg","/home/pi/"+prefix+"_p5.jpg")
            statusWin.addstr(1,1, 'Saved webcam and opencv images to prefix '+prefix)
        elif keyp == 'e':


            img = Image("/dev/shm/lastsnap.jpg")


            object = img.hueDistance(Color.BLUE)
            object.save("/dev/shm/p3.png")
            object.save("/dev/shm/p3.jpg") # for shape denoise handling

            #blobs = blue_distance.findBlobs()

            #object.draw(color=Color.PUCE, width=2)
            #blue_distance.show()
            #blue_distance.save("/dev/shm/p3.png")

            corners=img.findCorners()

            statusWin.clear()
            statusWin.addstr( 1, 1,  str(object.meanColor()))


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
            
            
            blobs.draw(color=Color.RED, width=2)


            num_corners = len(corners)
            num_blobs = len(blobs)
            statusWin.addstr(2,1, "Corners Found:" + str(num_corners))
            statusWin.addstr(3,1, "Blobs Found:" + str(num_blobs))

            img.save("/dev/shm/p4.png")
            img.save("/dev/shm/p4b.jpg")

            img2 = cv2.imread('/dev/shm/lastsnap.jpg')
            grey = cv2.imread('/dev/shm/p3.jpg',0)
            #grey = cv2.imread('/dev/shm/lastsnap.jpg',0)

            #worked are removing noise but took wayyyyyy too long
            #denos=cv2.fastNlMeansDenoising(grey, None, 10)

            # detection against a greyscale image. 
            # change thresholds against different backgrounds
            #ret, thresh = cv2.threshold( denos,80,80, 1)
            ret, thresh = cv2.threshold( grey,80,80,1)
            contours, h = cv2.findContours( thresh, 1,2 )

            # http://stackoverflow.com/questions/11424002/how-to-detect-simple-geometric-shapes-using-opencv

            cpent=0
            ctri=0
            csqr=0
            chc=0
            ccir=0
            for cnt in contours:
                approx = cv2.approxPolyDP(cnt,0.01*cv2.arcLength(cnt,True),True)
                #print len(approx)
                statusWin.addstr(3,20, "Contours Found:" + str(len(approx)))
                if len(approx)==5:
                    #print "pentagon"
                    cpent=cpent+1
                    #cv2.drawContours(img2,[cnt],0,255,-1)
                elif len(approx)==3:
                    #print "triangle"
                    ctri=ctri+1
                    cv2.drawContours(img2,[cnt],0,Color.RED,-1)
                elif len(approx)==4:
                    #print "square"
                    csqr=csqr+1
                    cv2.drawContours(img2,[cnt],0,Color.BLUE,-1)
                elif len(approx) == 9:
                    #print "half-circle"
                    chc=chc+1
                    cv2.drawContours(img2,[cnt],0,Color.GREEN,-1)
                elif len(approx) > 15:
                    #print "circle"
                    ccir=ccir+1
                    #cv2.drawContours(img2,[cnt],0,Color.PUCE,-1)

                statusWin.addstr(3,40, "pent=" + str(cpent)+" R.tri="+str(ctri)+" B.sqr="+str(csqr)+" G.hc="+str(chc)+" cir="+str(ccir))


            #cv2.imwrite("/dev/shm/pdenos.jpg",denos)
            cv2.imwrite("/dev/shm/pdenos.jpg",grey)
            cv2.imwrite("/dev/shm/p5.jpg",img2)


            # using the greyscale version from the shape detector detect bar codes

            scanner = zbar.ImageScanner()
            scanner.parse_config('enable')
            pil = PIL.Image.fromarray(grey)
            width, height = pil.size
            raw = pil.tostring()

            image = zbar.Image(width, height, 'Y800', raw)
            scanner.scan(image)

            fstr=''
            for symbol in image:
               fstr = fstr + ' decoded' + symbol.type + ' symbol '+ symbol.data

            statusWin.addstr(4,1, "barcode "+fstr)
               


            #img.save(js.framebuffer)


        elif keyp == 'v':
             pz.stop()
             pts = []
             row=2

             # create image
            
             #sonarImg=PIL.Image.new('RGB',(512,150),(255,255,255))
             sonarImg=PIL.Image.new('RGB',(250,150),(255,255,255))
             #irImg=Image.new('RGB',(1024,1024))
              

             scanWin.addstr(1,1,"Distance Map"          )
             scanWin.addstr(2,1, "Sonar")
             for span in range( 39, 75, 3 ):
               #irLine=""
               sonLine=""

               for stilt in range( 150, 30, -3 ):
                  pz.setOutput (pan, span)
                  pz.setOutput (tilt, stilt)
                  time.sleep( 0.1)
                  ir, distance, volts, actdist = readSensors()
                  #ir = pz.readInput(irSen)
                  #distance = int(hcsr04.getDistance())
                  #print "At pan,tilt: ",span,",",stilt,": ir Distance:", ir, " sonic distance: ", distance

                  #volts=min(1,ir*0.0048828125);  # // value from sensor * (5/1024) - if running 3.3.volts then change 5 to 3.3
                  #volts=min(1,ir*0.002929688);  # // value from sensor * (5/1024) - if running 3.3.volts then change 5 to 3.3

                  #actdist=65*pow(volts, -1.10);  #        // worked out from graph 65 = theretical distance / (1/Volts)S - luckylarry.co.uk

                  #print "ir act distance: ",actdist

	              # TODO: Save values and pos so build map

                  # rescale reading to ascii value

                  #irLine = irLine + asciiSensor( 400, 400-min(400,ir) ) 
                  #irImg.putpixel( ( stilt, span), pixelSensor( 400, 400-min(400,ir) ) ) 
                  #px=pixelSensor( 400, 400-min(400,ir) )
                  #px2=(px,px,0)
                  #sonarImg.putpixel( ( stilt+200, span), px2) 
                  #sonarImg.putpixel( ( stilt+200, span+1), px2) 
                  #sonarImg.putpixel( ( stilt+200, span+2), px2) 


                  #sonarImg.putpixel( ( stilt+201, span), px2) 
                  #sonarImg.putpixel( ( stilt+201, span+1), px2) 
                  #sonarImg.putpixel( ( stilt+201, span+2), px2) 

                  # sonarImg.putpixel( ( stilt+202, span), px2) 
                  #sonarImg.putpixel( ( stilt+202, span+1), px2) 
                  #sonarImg.putpixel( ( stilt+202, span+2), px2) 
                  #sonarImg.putpixel( ( stilt+200, span), (pixelSensor( 400, 400-min(400,ir) ),0,0) ) 

                  sonLine = sonLine + asciiSensor(80, distance )
                  px=pixelSensor(80, distance )
                  px2=(px,px,0)
                  #sonarImg.putpixel( (stilt, span), (pixelSensor(80, distance ),0,0))

                  sonarImg.putpixel( (stilt, span), px2)
                  sonarImg.putpixel( (stilt, span+1), px2)
                  sonarImg.putpixel( (stilt, span+2), px2)

                  sonarImg.putpixel( (stilt+1, span), px2)
                  sonarImg.putpixel( (stilt+1, span+1), px2)
                  sonarImg.putpixel( (stilt+1, span+2), px2)

                  sonarImg.putpixel( (stilt+2, span), px2)
                  sonarImg.putpixel( (stilt+2, span+1), px2)
                  sonarImg.putpixel( (stilt+2, span+2), px2)

               row=row+1
               #scanWin.addstr(row,1, sonLine+ " | "+ str(irLine))
               scanWin.addstr(row,1, sonLine)
               scanWin.refresh()

             pz.setOutput (pan, panVal)
             pz.setOutput (tilt, tiltVal)
             #irImg.save('/dev/shm/ir.png')
             sonarImg.save('/dev/shm/sonar.png')
        elif keyp == '8' or keyp == 'i' or ord(keyp) == 17:
            panVal = fwdPan
            tiltVal = fwdTilt
            pz.setOutput (pan, panVal)
            pz.setOutput (tilt, tiltVal)

            pz.stop()
            # get a sample for safe value

            fwdSafe=0
            #for c in range(0,20):
            #    fwdSafe = max(fwdSafe, int(hcsr04.getDistance()))
            #    time.sleep(0.1)
            pz.reverse(speed)
            #statusWin.clear()
            statusWin.addstr(1,1,'Forward '+ str(speed)+"     ")

 
            

        elif keyp == '4' or keyp == 'j' or ord(keyp) == 18:
            pz.spinRight(turnSpeed)
            #statusWin.clear()
            statusWin.addstr(1,1, 'Spin Right '+ str(speed)+"    ")
        elif keyp == '6' or keyp == 'l' or ord(keyp) == 19:
            pz.spinLeft(turnSpeed)
            #statusWin.clear()
            statusWin.addstr(1,1, 'Spin Left '+ str(speed)+"     ")
        elif keyp == '.' or keyp == '>':
            speed = min(100, speed+10)
            #statusWin.clear()
            statusWin.addstr(1,1, 'Speed+ '+ str(speed)+"     ")
        elif keyp == ',' or keyp == '<':
            speed = max (0, speed-10)
            #statusWin.clear()
            statusWin.addstr(1,1, 'Speed- '+ str(speed)+"    ")
        elif keyp == 'w':
            panVal = max (0, panVal - 5)
            #statusWin.clear()
            statusWin.addstr(1,1, 'Up ' + str(panVal)+"    ")
            pz.setOutput (pan, panVal)
            pz.setOutput (tilt, tiltVal)
        elif keyp == 'z':
            panVal = min (180, panVal + 5)
            #statusWin.clear()
            statusWin.addstr(1,1, 'Down '+ str(panVal)+"   ")
            pz.setOutput (pan, panVal)
            pz.setOutput (tilt, tiltVal)
        elif keyp == 'd' :
            tiltVal = max (0, tiltVal - 5)
            #statusWin.clear()
            statusWin.addstr(1,1,'Right '+ str(tiltVal)+"      ")
            pz.setOutput (pan, panVal)
            pz.setOutput (tilt, tiltVal)
        elif keyp == 'a' :
            tiltVal = min (180, tiltVal + 5)
            #statusWin.clear()
            statusWin.addstr(1,1, 'Left '+ str(tiltVal)+"     ")
            pz.setOutput (pan, panVal)
            pz.setOutput (tilt, tiltVal)
        elif keyp == 'f':
            #print 'Cam', camVal
            pz.setOutput (cam, 100)
            time.sleep(0.1)
            pz.setOutput( cam, 90)
        elif keyp == 'g':
            pz.setOutput (cam, 80)
            time.sleep(0.1)
            pz.setOutput( cam, 90)
        elif keyp =='q':
                curses.nocbreak(); stdscr.keypad(0); curses.echo()
                curses.endwin()
                abort()
        elif keyp == 's':
            panVal = 90
            tiltVal = 75
            #print 'Centre'
            pz.setOutput (pan, panVal)
            pz.setOutput (tilt, tiltVal)
        elif ord(keyp) == 3:
            break
        elif keyp == '5' or keyp == 'k':
            pz.stop()
            statusWin.addstr(1,1,'Stop')
        elif ord(keyp) == 3:
            break


        statusWin.refresh()

        if sensorLast < time.time(): 
           ir, distance, volts, actdist = readSensors()
           t=int(time.time())
           sensorLast=t+1

        
        #    ir = pz.readInput(irSen)
        #    distance = int(hcsr04.getDistance())

        leftRev=pz.readInput(leftCounter)
        if leftRev <> leftState:
             leftTotal = leftTotal + 1

        rightRev=pz.readInput(rightCounter)

        if rightRev <> rightState:
             rightTotal = rightTotal + 1

        leftState=leftRev
        rightState=rightRev

        #volts=min(0.1,ir*0.0029296875 )  #min(1,ir*0.006);  # // value from sensor * (5/1024) - if running 3.3.volts then change 5 to 3.3

        #actdist= (65*pow(volts, -1.10));  #        // worked out from graph 65 = theretical distance / (1/Volts)S - luckylarry.co.uk
        #sensorWin.clear()
        sensorWin.addstr(1,1, "Sonar Distance: "+ str(distance)+"    ")
        sensorWin.addstr(1,30, " Safe: "+ str(fwdSafe)+"        " )
        sensorWin.addstr(1,40, " iR Distance: "+ str(ir)+"   Actual: "+str(actdist)+"    " )
        sensorWin.addstr(2,1, "Left Counter: "+ str(leftTotal)+"        " )
        sensorWin.addstr(2,30, "Right Counter: "+ str(rightTotal)+"        " )


        sensorWin.refresh()

        # coli detection

        if( distance < fwdSafe ):
            #pz.stop()
            # clear value so it does not prevent any turning to avoid!
            #fwdSafe=0
            #statusWin.clear()
            statusWin.addstr(2,1, "Stopping.... Something too close      ")
            statusWin.refresh()
      
except KeyboardInterrupt:
    print

finally:
    hcsr04.cleanup()

    pz.cleanup()
