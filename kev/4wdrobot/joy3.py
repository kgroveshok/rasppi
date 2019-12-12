#import evdev
from evdev import InputDevice, categorize, ecodes

#creates object 'gamepad' to store the data
#you can call it whatever you like
gamepad = InputDevice('/dev/input/event1')

#prints out device info at start
print(gamepad)

#evdev takes care of polling the controller in a loop
#for event in gamepad.read_loop():
#    print(categorize(event))

#button code variables (change to suit your device)
aBtn = 34
bBtn = 36
xBtn = 35
yBtn = 23

up = 46
down = 32
left = 18
right = 33

start = 24
select = 49

lTrig = 37
rTrig = 50

#prints out device info at start
print(gamepad)


# stop BTN_BASE3
# up BTN_TOP2
# down BTN_BASE
# left BTN_BASE2
# right BTN_PINKIE


#loop and filter by event code and print the mapped label
for event in gamepad.read_loop():
    #print(categorize(event))
    if event.type != ecodes.EV_SYN:
        if event.type in ecodes.bytype:
            codename = ecodes.bytype[event.type][event.code]
            print(codename)
       
    if event.type == ecodes.EV_KEY:
        if event.value == 1:
            if event.code == yBtn:
                print("Y")
            elif event.code == bBtn:
                print("B")
            elif event.code == aBtn:
                print("A")
            elif event.code == xBtn:
                print("X")

            elif event.code == up:
                print("up")
            elif event.code == down:
                print("down")
            elif event.code == left:
                print("left")
            elif event.code == right:
                print("right")

            elif event.code == start:
                print("start")
            elif event.code == select:
                print("select")

            elif event.code == lTrig:
                print("left bumper")
            elif event.code == rTrig:
                print("right bumper")

