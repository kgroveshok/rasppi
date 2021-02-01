#!/usr/bin/python
# Based on Picon Zero Motor Test
#

# Bottle filling machine


# Hardware pins



# Processing Stages

from enum import Enum
import piconzero as pz, time


#hcsr04.init()

class stage:
    Selection = 1
    LoadCaddy = 2
    FindingBottleMark = 3
    BottlePresentScan =4
    Filling = 5
    Stop = 6


pz.init()

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


def setLED():
#   dispLED1 = 1
#   dispLED2 = 1
#   dispLED3 = 1
#   dispLED4 = 1
#   dispLED5 = 1
   # set led states
   pz.setOutput( pinLED1, dispLED1 )
   pz.setOutput( pinLED2, dispLED2 )
   pz.setOutput( pinLED3, dispLED3 )
   pz.setOutput( pinLED4, dispLED4 )
   pz.setOutput( pinLED5, dispLED5 )


senseButSelection = 0
senseButStartStop = 0

def readSensors():
    return ( not pz.readInput( pinButSelection ), not pz.readInput( pinButStartStop ), not pz.readInput( pinCaddyIn) )



    #TODO senseCaddyIn = 0
    #TODO senseCaddyOut = 0
    #TODO senseBottleMark = 0
    #TODO senseBottlePresent = 0


def caddyIn():
    time.sleep(2)
    pz.setOutput( pinCaddyDrive, 80 )
    time.sleep(2)
    pz.setOutput( pinCaddyDrive, 90 )
    time.sleep(2)
    pz.setOutput( pinCaddyDrive, 110 )
    time.sleep(2)
    pz.setOutput( pinCaddyDrive, 90 )
    pass

def caddyNext():
    pass


# init

# selection options
currentStage = stage.Selection


# Pump selection running times
pumpFlushTime = 20
pumpProg = [ 0, 0, 0, 0, 0 ]

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
pz.setOutputConfig( pinLED4, 0 )
pz.setOutputConfig( pinLED5, 0 )
pz.setOutputConfig( pinCaddyDrive, 2 )


# TODO set pump pin
# TODO set caddy motor pin

# main loop



caddyIn()
caddyNext()



while True:
       



        setLED()
        ( senseButSelection, senseButStartStop, senseCaddyIn) = readSensors()

        print( ":%d-%d-%d-%d" % ( senseButSelection, senseButStartStop, pressedSelection,  currentStage) )
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
                pass

        if not senseButStartStop and pressedStartStop :
                pressedStartStop = False

        if currentStage == stage.Selection:
            dispLED1 = fillSelection == 0
            dispLED2 = fillSelection == 1
            dispLED3 = fillSelection == 2
            dispLED4 = fillSelection == 3
            dispLED5 = fillSelection == 4
            print( "4")
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
                if fillSelection > 4 :
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
                dispLED1 = True
                dispLED2 = False
                dispLED3 = False
                dispLED4 = False
                dispLED5 = False
                currentStage = stage.LoadCaddy
                time.sleep(2)


        elif currentStage == stage.LoadCaddy:
            dispLED2 = True
            currentStage = stage.FindingBottleMark
            caddyPos = 0
            time.sleep(2)
            #TODO
            
        elif currentStage == stage.FindingBottleMark:

            dispLED3 = True
            dispLED4 = False
            dispLED5 = False
            currentStage = stage.BottlePresentScan
            time.sleep(2)


            if senseCaddyIn :
                currentStage = stage.Selection
                # TODO stop caddy
            else:
                #TODO move caddy
                pass
        elif currentStage == stage.BottlePresentScan:
            dispLED4 = True
            dispLED5 = False
            currentStage = stage.Filling
            time.sleep(2)
            #TODO
            pass
        elif currentStage == stage.Filling:
            dispLED5 = True
            currentStage = stage.FindingBottleMark
            time.sleep(2)
 #          caddyPos = caddyPos + 10
            #TODO 
            pass
            


#finally:
#    hcsr04.cleanup()

pz.cleanup()
