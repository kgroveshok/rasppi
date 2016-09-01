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
fwdPan=75
fwdTilt=90
pz.setOutput (pan, panVal)
pz.setOutput (tilt, tiltVal)
pz.setOutput (cam, camVal)
print "Tests the motors by using the arrow keys to control. number keys. 5 to stop. IJLM. K=stop"
print "Use , or < to slow down"
print "Use . or > to speed up"
print "V to distance scan"
print "Move cam. F and H. G = Default"
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
        if keyp == '2' or keyp == 'm' or ord(keyp) == 16:
            pz.forward(speed)
            print 'Reverse', speed
        elif keyp == 'v':
             pz.stop()
             for span in range( 40, 75,5 ):
               for stilt in range( 30, 150, 5 ):
                  pz.setOutput (pan, span)
                  pz.setOutput (tilt, stilt)
                  time.sleep( 0.15)
                  ir = pz.readInput(irSen)
                  print "At pan,tilt: ",span,",",stilt,": Distance:", ir

                  volts=min(1,ir*0.0048828125);  # // value from sensor * (5/1024) - if running 3.3.volts then change 5 to 3.3

                  actdist=65*pow(volts, -1.10);  #        // worked out from graph 65 = theretical distance / (1/Volts)S - luckylarry.co.uk

                  print "act distance: ",actdist
			  
                  # TODO: Save values and pos so build map
             pz.setOutput (pan, panVal)
             pz.setOutput (tilt, tiltVal)
        elif keyp == '8' or keyp == 'i' or ord(keyp) == 17:
            panVal = fwdPan
            tiltVal = fwdTilt
            pz.setOutput (pan, panVal)
            pz.setOutput (tilt, tiltVal)
            pz.reverse(speed)
            print 'Forward', speed
        elif keyp == '4' or keyp == 'j' or ord(keyp) == 18:
            pz.spinRight(turnSpeed)
            print 'Spin Right', speed
        elif keyp == '6' or keyp == 'l' or ord(keyp) == 19:
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
        elif keyp == 'z':
            panVal = min (180, panVal + 5)
            print 'Down', panVal
            pz.setOutput (pan, panVal)
            pz.setOutput (tilt, tiltVal)
        elif keyp == 'd' :
            tiltVal = max (0, tiltVal - 5)
            print 'Right', tiltVal
            pz.setOutput (pan, panVal)
            pz.setOutput (tilt, tiltVal)
        elif keyp == 'a' :
            tiltVal = min (180, tiltVal + 5)
            print 'Left', tiltVal
            pz.setOutput (pan, panVal)
            pz.setOutput (tilt, tiltVal)
        elif keyp == 'f':
            print 'Cam', camVal
            pz.setOutput (cam, 100)
            time.sleep(0.1)
            pz.setOutput( cam, 90)
        elif keyp == 'g':
            camVal = 90
            print 'Centre Cam', camVal
            pz.setOutput (cam, camVal)
        elif keyp == 'h':
            pz.setOutput (cam, 80)
            time.sleep(0.1)
            pz.setOutput( cam, 90)
        elif keyp == 's':
            panVal = tiltVal = 90
            print 'Centre'
            pz.setOutput (pan, panVal)
            pz.setOutput (tilt, tiltVal)
        elif ord(keyp) == 3:
            break
        elif keyp == '5' or keyp == 'k':
            pz.stop()
            print 'Stop'
        elif ord(keyp) == 3:
            break




        ir = pz.readInput(irSen)
        distance = int(hcsr04.getDistance())
        print "Rear Distance:", distance, " iR Distance:", ir, 

except KeyboardInterrupt:
    print

finally:
    hcsr04.cleanup()

    pz.cleanup()
