#!/usr/bin/python
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
import time
import sys
import tty
import termios
import hcsr04
import select
import curses
import random


stdscr = curses.initscr()
curses.noecho()
curses.cbreak()
stdscr.keypad(1)
#nodelay(1)
hcsr04.init()



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

speed = 80
turnSpeed=100

# Define which pins are the servos and sensors

leftWheel = 0
rightWheel = 1


# init all hardware


pz.init()




helpWin.addstr(1,1, "Tests the motors by using the arrow keys to control. num keys. 5 to stop. IJLM. K=stop")
helpWin.addstr(2, 1, "Use , or < to slow down. Use . or > to speed up. V to distance scan")
helpWin.refresh()

# main loop

try:
    while True:
        #keyp = readkey()
        #keyp = readchar()
        keyp = GetChar(False)
        if keyp == '2' or keyp == 'm' or ord(keyp) == 16:
            pz.forward(speed)
            statusWin.addstr(1,1, 'Reverse '+ str(speed)+"    ")
        elif keyp == '8' or keyp == 'j' or ord(keyp) == 18:
            pz.stop()
            # get a sample for safe value

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
        elif keyp =='q':
                curses.nocbreak(); stdscr.keypad(0); curses.echo()
                curses.endwin()
                abort()
        elif keyp == '5' or keyp == 'k':
            pz.stop()

        statusWin.refresh()
      
except KeyboardInterrupt:
    print

finally:
    hcsr04.cleanup()

    pz.cleanup()
