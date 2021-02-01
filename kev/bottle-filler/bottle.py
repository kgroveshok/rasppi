#!/usr/bin/python
# Based on Picon Zero Motor Test
#

# Bottle filling machine


# Hardware pins



# Processing Stages

from enum import Enum
import piconzero as pz, time


pz.init()
hcsr04.init()

stage = Enum( 'Selection', 'LoadCaddy', 'FindingBottleMark', \
      'BottlePresentScan', 'Filling', 'Stop' )


# machine pin out

pinCaddyIn = 0
pinCaddyOut = 1
pinBottleMark = 2
pinButSelection = 0
pinButStartStop = 3

pinCaddyDrive = 0

pinLED1 = 1
pinLED2 = 2
pinLED3 = 3
pinLED4 = 4
pinLED5 = 5


pinPump = 0



senseButSelection = 0
senseButStartStop = 0
senseCaddyIn = 0
senseCaddyOut = 0
senseBottleMark = 0
senseBottlePresent = 0

dispLED1 = 0
dispLED2 = 0
dispLED3 = 0
dispLED4 = 0
dispLED5 = 0


def setLED:
   # set led states
   pz.setOutput( pinLED1, dispLED1 )
   pz.setOutput( pinLED2, dispLED2 )
   pz.setOutput( pinLED3, dispLED3 )
   pz.setOutput( pinLED4, dispLED4 )
   pz.setOutput( pinLED5, dispLED5 )



def readSensors():
    senseButSelection = pz.readInput( pinButSelection )
    senseButStartStop = pz.readInput( pinButStartStop )
    #TODO senseCaddyIn = 0
    #TODO senseCaddyOut = 0
    #TODO senseBottleMark = 0
    #TODO senseBottlePresent = 0

# init

# selection options
currentStage = stage.Selection


# Pump selection running times
pumpFlushTime = 20
pumpProg = [ 0, 0, 0, 0, 0 ]



# handle selection button bounce

fillSelection = 0
pressedSelection = False


# setup I/O

setInputConfig( pinButSelection, 0 )
setInputConfig( pinButStartStop, 0 )

#setOutputConfig( pinCaddyDrive, 

setOutputConfig( pinLED1, 0 )
setOutputConfig( pinLED2, 0 )
setOutputConfig( pinLED3, 0 )
setOutputConfig( pinLED4, 0 )
setOutputConfig( pinLED5, 0 )


# TODO set pump pin
# TODO set caddy motor pin

# main loop

try:
    while True:

        setLED()
        readSensors()

        if currentStage != stage.Selection :
           # TODO emergency stop if start button is pressed when running
           if senseButStartStop :
                # TODO stop pump
                # TODO stop servo

        if currentStage == stage.Selection:
            # select mode
            if senseButSelection :
                # selection button pressed
                pressedSelection = True
                print "Holding down selection button"

            if !senseButSelection and pressedSelection :
                # selection button has been released

                pressedSelection = False
                
                # Cycle selection
                fillSelection++
                if fillSelection > 4 :
                    fillSelection = 0
                print( "Fill selection %d" % fillSelection )
                dispLED1 = fillSelection == 0
                dispLED2 = fillSelection == 1
                dispLED3 = fillSelection == 2
                dispLED4 = fillSelection == 3
                dispLED5 = fillSelection == 4

            if senseButSelection and senseButStartStop :
                runPump = pumpFlushTime
                pz.setMotor( pinPump, 50)
                while runPump :
                    print( "Run pump pulse %d" % runPump )
                    # TODO run pump
                    runPump--
                pz.setMotor( pinPump, 0)


            #    dispLED1 = True
            #    dispLED2 = True
            #    dispLED3 = True
            #    dispLED4 = True
            #    dispLED5 = True

            if senseButStartStop and !senseButSelection :
                # TODO start the system
                print( "Start fill process")
                # currentStage = stage.LoadCaddy
                dispLED1 = False
                dispLED2 = False
                dispLED3 = False
                dispLED4 = False
                dispLED5 = False


        if currentStage == stage.LoadCaddy:
            #TODO
            pass
        if currentStage == stage.FindingBottleMark:
            #TODO
            pass
        if currentStage == stage.BottlePresentScan:
            #TODO
            pass
        if currentStage == stage.Filling:
            #TODO
            pass
            


finally:
#    hcsr04.cleanup()

    pz.cleanup()
