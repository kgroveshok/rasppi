#!/usr/bin/python
# Based on Picon Zero Motor Test
#

# Bottle filling machine


# Hardware pins



# Processing Stages

from enum import Enum
import piconzero as pz, time
import hcsr04, time
#import RPi.GPIO as GPIO
from gpiozero import LED
import os


class stage:
    Selection = 1
    LoadCaddy = 2
    FindingBottleMark = 3
    BottlePresentScan =4
    FillInsert = 5
    Filling = 6
    Stop = 7


pz.init()
hcsr04.init()

# machine pin out

pinCaddyIn = 0
pinCaddyOut = 1
pinBottleMark = 2
pinButSelection = 0
pinButStartStop = 3
pinFillInsert = 1

pinCaddyDrive = 0

pinLED1 = 3
pinLED2 = 4
pinLED3 = 5
#pinLED4 = 4
#pinLED5 = 5


pinPump = 0



senseButSelection = 0
senseButStartStop = 0
senseCaddyIn = 0
senseCaddyOut = 0
senseBottleMark = 0
senseBottlePresent = 0

# max distance a bottle can be away to detect it is present
threshBottlePresent = 5

dispLED1 = 0
dispLED2 = 0
dispLED3 = 0
dispLED4 = 0
dispLED5 = 0


displayLED = [ [ 0, False, False, False ], \
    [ 0, False, False, True ],
    [ 0, False, True, False ],
    [ 0, False, True, True ],
    [ 0, True, False, False ],
    [ 0, True, False, True ],
    [ 0, True, True, False ],
    [ 0, True, True, True ] ]


pin1=LED(18)
pin2=LED(27)
pin3=LED(22)

def setLED():
#   dispLED1 = 1
#   dispLED2 = 1
#   dispLED3 = 1
#   dispLED4 = 1
#   dispLED5 = 1
   # set led states
#   pz.setOutput( pinLED1, dispLED1 )
#   pz.setOutput( pinLED2, dispLED2 )
#   pz.setOutput( pinLED3, dispLED3 )
#   pz.setOutput( pinLED4, dispLED4 )
#   pz.setOutput( pinLED5, dispLED5 )
#outputs = [ pinLED1, pinLED2, pinLED3 ]
#        outputs = [ 18, 27, 22 ]
#GPIO.setmode(GPIO.BCM)


        for p in range(0,8):
            if displayLED[p][0]:
                print( "LED %d on" % (p))
                if displayLED[p][1]:
                    pin1.on()
                else:
                    pin1.off()
                if displayLED[p][2]:
                    pin2.on()
                else:
                    pin2.off()
                if displayLED[p][3]:
                    pin3.on()
                else:
                    pin3.off()
#                time.sleep(0.25)


#for i in range( 0, 3) :
#    GPIO.setup(outputs[i],GPIO.OUT)
#    #GPIO.setup(outputs[i],GPIO.OUT)

#        print(" value %d" % jj )
#        bits=format(jj,'03b')
#        if bits[0]=='1':
#            pin1.on()
#        else:
#            pin1.off()
#        if bits[1]=='1':
#            pin2.on()
#        else:
#            pin2.off()
#
#        if bits[2]=='1':
#            pin3.on()
#        else:
#            pin3.off()
#        for ii in range(0,3):
#            GPIO.output(outputs[ii], bits[2-ii]=='1')
#            LED(outputs[ii], bits[2-ii]=='1')
            #pz.setOutput( outputs[ii], bits[2-ii]=='1' )
#            print("  led %d :%d: %s" % ( ii, bits[2-ii]=='1', format(jj,'03b')))
#        time.sleep(10)



senseButSelection = 0
senseButStartStop = 0

def readSensors():
    return ( not pz.readInput( pinButSelection ), not pz.readInput( pinButStartStop ), not pz.readInput( pinCaddyIn), int( hcsr04.getDistance()) )



    #TODO senseCaddyIn = 0
    #TODO senseCaddyOut = 0
    #TODO senseBottleMark = 0
    #TODO senseBottlePresent = 0

# TODO Caddy loading speeds

caddySpeedStop=88
#caddySpeedStop=90
caddySpeedIn=50
#caddySpeedIn=78
caddySpeedOut=98

# TODO tune to pipe bottle insertion angles
fillPipeIn=70
fillPipeOut=160

# TODO change durations for required volumes once pump installed

fillPrograms = [ 1,5, 10, 15, 20, 40, 1, 1 ]


def caddyIn():

        print( "Stop")
        pz.setOutput( pinCaddyDrive, caddySpeedStop )
        time.sleep(1)
        print( "In")
        pz.setOutput( pinCaddyDrive, caddySpeedIn )
        time.sleep(1)
        print( "Stop")
        pz.setOutput( pinCaddyDrive, caddySpeedStop )
        time.sleep(1)
        print( "Out")
        pz.setOutput( pinCaddyDrive, caddySpeedOut )
        time.sleep(1)
        print( "Stop")
        pz.setOutput( pinCaddyDrive, caddySpeedStop )
        time.sleep(1)
        pz.setOutput( pinCaddyDrive, caddySpeedStop )

def caddyNext():
    pass


# init

# selection options
currentStage = stage.Selection


# Pump selection running times
pumpFlushTime = 20
#pumpProg = [ 0, 0, 0, 0, 0 ]

caddyPos = 0

# handle selection button bounce

fillSelection = 0
pressedSelection = False
pressedStartStop = False


# setup I/O

pz.setInputConfig( pinButSelection, 0, True )
pz.setInputConfig( pinButStartStop, 0, True )

#setOutputConfig( pinCaddyDrive, 

pz.setOutputConfig( pinLED1, 0 )
pz.setOutputConfig( pinLED2, 0 )
pz.setOutputConfig( pinLED3, 0 )
#pz.setOutputConfig( pinLED4, 0 )
#pz.setOutputConfig( pinLED5, 0 )
pz.setOutputConfig( pinCaddyDrive, 2 )
pz.setOutputConfig( pinFillInsert, 2 )


# TODO set pump pin
# TODO set caddy motor pin

# main loop



caddyIn()
caddyNext()


#try:
#    while True:
#        distance = int(hcsr04.getDistance())
#        print "Distance:", distance
#        time.sleep(1)
#except KeyboardInterrupt:
#    print
#finally:
#    hcsr04.cleanup()

stopBottles=False

l=0






try:
    while not stopBottles:
       



        setLED()
        ( senseButSelection, senseButStartStop, senseCaddyIn, senseBottlePresent ) = readSensors()

        print( ":%d-%d-%d-%d-%d" % ( senseButSelection, senseButStartStop, pressedSelection,  currentStage, senseBottlePresent) )
        print( "1")

        if currentStage != stage.Selection :
           print( "2")
           # TODO emergency stop if start button is pressed when running
           if senseButStartStop :
                print( "3")
                print(" emergency stop!")
                currentStage = stage.Selection
                pressedStartStop = True
                # TODO stop pump
                # TODO stop servo
                pz.setOutput(pinCaddyDrive, 90)

           # As process is running set the display to
           # be the current stage number
           for s in range(0,8):
                displayLED[s][0]=0
           displayLED[currentStage+1][0]=1

        if not senseButStartStop and pressedStartStop :
                pressedStartStop = False

        if currentStage == stage.Selection:
            pz.setOutput( pinFillInsert, fillPipeOut)
            for p in range(0,8):
                if fillSelection == p:
                    displayLED[p][0]=1
                else:
                    displayLED[p][0]=0

#           dispLED1 = fillSelection == 0
#           dispLED2 = fillSelection == 1
#           dispLED3 = fillSelection == 2
#           dispLED4 = fillSelection == 3
#           dispLED5 = fillSelection == 4
            print( "4 %d" % (fillSelection))
            # select mode
            if senseButSelection :
                print( "5")
                # selection button pressed
                pressedSelection = True
                print "Holding down selection button"

            if not senseButSelection and pressedSelection :
                print( "6")
                # selection button has been released

                pressedSelection = False
                
                # Cycle selection
                fillSelection = fillSelection + 1
                if fillSelection > 7:
                    fillSelection = 0
                print( "Fill selection %d" % fillSelection )

            if senseButSelection and senseButStartStop :
                print( "7")
                runPump = pumpFlushTime
                pz.setMotor( pinPump, 50)
                while runPump :
                    print( "Run pump pulse %d" % runPump )
                    # TODO run pump
                    runPump = runPump - 1
                pz.setMotor( pinPump, 0)


            #    dispLED1 = True
            #    dispLED2 = True
            #    dispLED3 = True
            #    dispLED4 = True
            #    dispLED5 = True

            if senseButStartStop and not senseButSelection and not pressedStartStop:

                # TODO start the system
                print( "Start fill process")
                # currentStage = stage.LoadCaddy
                displayLED[0][0]=1
                dispLED1 = True
                dispLED2 = False
                dispLED3 = False
                dispLED4 = False
                dispLED5 = False
                currentStage = stage.LoadCaddy
                time.sleep(2)

                if fillSelection == 7:
                    # power off
                    currentStage = stage.Selection
                    os.system("sudo halt -p")


        elif currentStage == stage.LoadCaddy:
            dispLED2 = True
            setLED()
            currentStage = stage.FindingBottleMark
            caddyPos = 0
            time.sleep(2)
            # TODO add sensor check and remove counter
            pz.setOutput( pinCaddyDrive, caddySpeedOut )
            print( "Put Caddy Out" )
            time.sleep(5)
            pz.setOutput( pinCaddyDrive, caddySpeedStop )
            time.sleep(1)
            pz.setOutput( pinCaddyDrive, caddySpeedStop )
            #TODO
            
        elif currentStage == stage.FindingBottleMark:

            dispLED3 = True
            dispLED4 = False
            dispLED5 = False
            setLED()
            currentStage = stage.BottlePresentScan
            pz.setOutput( pinFillInsert, fillPipeOut)
            time.sleep(2)


            # TODO add sensor check and remove counter
            move = 5
            pz.setOutput( pinCaddyDrive, caddySpeedIn )
            while move > 0 :
                
                print( "Finding bottle marker" )

                move = move -1
                time.sleep(2)
            pz.setOutput( pinCaddyDrive, caddySpeedStop )
            time.sleep(1)
            pz.setOutput( pinCaddyDrive, caddySpeedStop )

            if senseCaddyIn :
                currentStage = stage.Selection
                # TODO stop caddy
            else:
                #TODO move caddy
                pass
        elif currentStage == stage.BottlePresentScan:
            dispLED4 = True
            dispLED5 = False
            setLED()
            print( "Bottle present at this slot?" )
            time.sleep(2)
            if senseBottlePresent < threshBottlePresent :
                # Bottle is present so fill it
                currentStage = stage.FillInsert
                print( "Yes" )
            else:
                # No bottle is present so find the next one
                currentStage = stage.FindingBottleMark
                print( "No" )
            #TODO
            pass
        elif currentStage == stage.FillInsert:
            setLED()
            print( "Insert fill pipe" )
            pz.setOutput( pinFillInsert, fillPipeIn)
            time.sleep(2)
            currentStage = stage.Filling


        elif currentStage == stage.Filling:
            print( "Fill bottle" )
            dispLED5 = True
            setLED()
            currentStage = stage.FindingBottleMark
            time.sleep(fillPrograms[fillSelection])
 #          caddyPos = caddyPos + 10
            #TODO 
            pass
            

except KeyboardInterrupt:
    stopBottles = True

#finally:
hcsr04.cleanup()

pz.cleanup()
