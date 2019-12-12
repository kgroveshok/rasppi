#!/usr/bin/python
#from __future__ import print_function
#import sys
#from psychopy.hardware import joystick
#from psychopy import visual
#
##init
#joystick.backend = 'pygame' # must match the Window
#win = visual.Window([400,400], winType=joystick.backend)
#
#j = joystick.Joystick(0)
#
#while True:
#	win.flip() # flipping updates the joystick info
#	val = ["{:6.3f}".format(i) for i in j.getAllAxes()]
#	buttons = [int(i) for i in j.getAllButtons()]
#	print("val: {}, {}".format(val, buttons), end='\r')
#    sys.stdout.flush()



#!/usr/bin/python
import pyglet

#window = pyglet.window.Window(width=400, height=400)

# open first joystick
joysticks = pyglet.input.get_joysticks()  # requires pyglet 1.2
if joysticks:
	joystick = joysticks[0]
else:
	print("ERROR: no joystick")
	exit()
joystick.open()

#@window.event
#def on_draw():
#	window.clear()

#@window.event
#def on_key_press(symbol, modifiers):
#	print("keypress")
#	print("query based joystick position: {}".format(joystick.x))
	
@joystick.event
def on_joybutton_press(joystick, button):
	print("event based joystick response")

pyglet.app.run()
