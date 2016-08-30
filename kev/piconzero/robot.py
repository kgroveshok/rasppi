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

# End of single character reading
#======================================================================

speed = 60
turnSpeed=100
neckSpeed = 60

# Define which pins are the servos
pan = 0
tilt = 1
grip = 2

pz.init()

# Set output mode to Servo
pz.setOutputConfig(pan, 2)
pz.setOutputConfig(tilt, 2)
pz.setOutputConfig(grip, 2)

# Centre all servos
panVal = 90
tiltVal = 90
gripVal = 90
pz.setOutput (pan, panVal)
pz.setOutput (tilt, tiltVal)
pz.setOutput (grip, gripVal)
print "Tests the motors by using the arrow keys to control"
print "Use , or < to slow down"
print "Use . or > to speed up"
print "Neck. WADZ. S = centre"
print "Speed changes take effect when the next arrow key is pressed"
print "Press Ctrl-C to end"
print


# main loop
try:
    while True:
        #keyp = readkey()
        keyp = readchar()
        #keyp = GetChar(False)
        if ord(keyp) == 16:
            pz.forward(speed)
            print 'Forward', speed
        elif ord(keyp) == 17:
            pz.reverse(speed)
            print 'Reverse', speed
        elif ord(keyp) == 18:
            pz.spinRight(turnSpeed)
            print 'Spin Right', speed
        elif ord(keyp) == 19:
            pz.spinLeft(turnSpeed)
            print 'Spin Left', speed
        elif keyp == '.' or keyp == '>':
            speed = min(100, speed+10)
            print 'Speed+', speed
        elif keyp == ',' or keyp == '<':
            speed = max (0, speed-10)
            print 'Speed-', speed
        elif keyp == 'w':
            panVal = max (0, panVal - 5)
            print 'Up', panVal
            pz.setOutput (pan, panVal)
            pz.setOutput (tilt, tiltVal)
            pz.setOutput (grip, gripVal)
        elif keyp == 'z':
            panVal = min (180, panVal + 5)
            print 'Down', panVal
            pz.setOutput (pan, panVal)
            pz.setOutput (tilt, tiltVal)
            pz.setOutput (grip, gripVal)
        elif keyp == 'd' :
            tiltVal = max (0, tiltVal - 5)
            print 'Right', tiltVal
            pz.setOutput (pan, panVal)
            pz.setOutput (tilt, tiltVal)
            pz.setOutput (grip, gripVal)
        elif keyp == 'a' :
            tiltVal = min (180, tiltVal + 5)
            print 'Left', tiltVal
            pz.setOutput (pan, panVal)
            pz.setOutput (tilt, tiltVal)
            pz.setOutput (grip, gripVal)
        elif keyp == 'g':
            gripVal = max (0, gripVal - 5)
            print 'Open', gripVal
            pz.setOutput (pan, panVal)
            pz.setOutput (tilt, tiltVal)
            pz.setOutput (grip, gripVal)
        elif keyp == 'h':
            gripVal = min (180, gripVal + 5)
            print 'Close', gripVal
            pz.setOutput (pan, panVal)
            pz.setOutput (tilt, tiltVal)
            pz.setOutput (grip, gripVal)
        elif keyp == 's':
            panVal = tiltVal = gripVal = 90
            print 'Centre'
            pz.setOutput (pan, panVal)
            pz.setOutput (tilt, tiltVal)
            pz.setOutput (grip, gripVal)
        elif ord(keyp) == 3:
            break
        elif keyp == 'q':
            pz.stop()
            print 'Stop'
        elif ord(keyp) == 3:
            break




        distance = int(hcsr04.getDistance())
        print "Distance:", distance,

except KeyboardInterrupt:
    print

finally:
    hcsr04.cleanup()

    pz.cleanup()
