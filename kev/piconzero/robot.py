#!/usr/bin/python
# Picon Zero Motor Test
# Moves: Forward, Reverse, turn Right, turn Left, Stop - then repeat
# Press Ctrl-C to stop
#
# To check wiring is correct ensure the order of movement as above is correct

import piconzero as pz, time

#======================================================================
# Reading single character by forcing stdin to raw mode
import sys
import tty
import termios
import hcsr04
import select
import curses
import random
from bisect import bisect

stdscr = curses.initscr()
curses.noecho()
curses.cbreak()
stdscr.keypad(1)
#nodelay(1)
hcsr04.init()


def asciiSensor( maxVal, reading ):

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

    OldRange = (maxVal - 0)  
    NewRange = (255 - 0)  
    NewValue = (((mval - 0) * NewRange) / OldRange) + 0

 

    lum=255-NewValue
    row=bisect(zonebounds,lum)
    possibles=greyscale[row]
    return possibles[random.randint(0,len(possibles)-1)]



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
sensorWin = curses.newwin(3,80, 6, 0)
statusWin = curses.newwin(5,80, 9, 0)
scanWin = curses.newwin(30, 90, 15, 0)

helpWin.border()
sensorWin.border()
statusWin.border()
scanWin.border()


# End of single character reading
#======================================================================

speed = 60
turnSpeed=100
neckSpeed = 60

# Define which pins are the servos
pan = 0
tilt = 1
cam = 2
irSen=3

pz.init()

# Set output mode to Servo
pz.setOutputConfig(pan, 2)
pz.setOutputConfig(tilt, 2)
pz.setOutputConfig(cam, 2)

pz.setInputConfig(irSen, 1)     # set input 0 to Analog

# Centre all servos
panVal = 90
tiltVal = 90
camVal = 90
fwdPan=90
fwdTilt=90
pz.setOutput (pan, panVal)
pz.setOutput (tilt, tiltVal)
pz.setOutput (cam, camVal)
helpWin.addstr(1,1, "Tests the motors by using the arrow keys to control. number keys. 5 to stop. IJLM. K=stop")
helpWin.addstr(2, 1, "Use , or < to slow down. Use . or > to speed up. V to distance scan")
helpWin.addstr(3,1, "Move cam. F and G. Neck. WADZ. S = centre")
helpWin.refresh()
#print "Speed changes take effect when the next arrow key is pressed"
#print "Press Ctrl-C to end"
#print


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
        elif keyp == 'v':
             pz.stop()
             pts = []
             row=2

             #scanWin.clear()
	     ASCII_CHARS = [ '#', '?', '%', '.', 'S', '+', '.', '-', '*', ':', ',', '@',' ',' ']




                              
             scanWin.addstr(1,1,"Distance Map"          )
             scanWin.addstr(2,1, "Sonar                    : ir")
             for span in range( 49, 75, 3 ):
               irLine=""
               sonLine=""

               for stilt in range( 150, 30, -3 ):
                  pz.setOutput (pan, span)
                  pz.setOutput (tilt, stilt)
                  time.sleep( 0.1)
                  ir = pz.readInput(irSen)
                  distance = int(hcsr04.getDistance())
                  #print "At pan,tilt: ",span,",",stilt,": ir Distance:", ir, " sonic distance: ", distance

                  #volts=min(1,ir*0.0048828125);  # // value from sensor * (5/1024) - if running 3.3.volts then change 5 to 3.3
                  volts=min(1,ir*0.002929688);  # // value from sensor * (5/1024) - if running 3.3.volts then change 5 to 3.3

                  actdist=65*pow(volts, -1.10);  #        // worked out from graph 65 = theretical distance / (1/Volts)S - luckylarry.co.uk

                  #print "ir act distance: ",actdist

	          # TODO: Save values and pos so build map

                  # rescale reading to ascii value

                  #m=200
                  #rwidth=m/12
                  #r=min(m,ir)/rwidth
                  #c=ASCII_CHARS[ min(m,r) ]
                  #irLine = irLine + c
                  irLine = irLine + asciiSensor( 400, 400-min(400,ir) ) 

                  #m=80
                  #rwidth=m/12
                  #r=min(m,distance)/rwidth
                  #c=ASCII_CHARS[ min(m,r) ]
                  #sonLine = sonLine + c
                  sonLine = sonLine + asciiSensor(80, distance )

               row=row+1
               scanWin.addstr(row,1, sonLine+ " | "+ str(irLine))
               scanWin.refresh()

             pz.setOutput (pan, panVal)
             pz.setOutput (tilt, tiltVal)
        elif keyp == '8' or keyp == 'i' or ord(keyp) == 17:
            panVal = fwdPan
            tiltVal = fwdTilt
            pz.setOutput (pan, panVal)
            pz.setOutput (tilt, tiltVal)
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
                exit
        elif keyp == 's':
            panVal = tiltVal = 90
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

        ir = pz.readInput(irSen)
        distance = int(hcsr04.getDistance())
        #sensorWin.clear()
        sensorWin.addstr(1,1, "Sonar Distance: "+ str(distance)+"    ")
        sensorWin.addstr(1,40, " iR Distance: "+ str(ir)+"        " )
        sensorWin.refresh()

        # coli detection

        if( distance < 20 ):
            pz.stop()
            #statusWin.clear()
            statusWin.addstr(2,1, "Stopping.... Something too close      ")
            statusWin.refresh()
      
except KeyboardInterrupt:
    print

finally:
    hcsr04.cleanup()

    pz.cleanup()
