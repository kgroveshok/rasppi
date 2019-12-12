#!/usr/bin/python
from __future__ import print_function
import sys
from psychopy.hardware import joystick
from psychopy import visual

#init
joystick.backend = 'pygame' # must match the Window
win = visual.Window([400,400], winType=joystick.backend)

j = joystick.Joystick(0)

while True:
	win.flip() # flipping updates the joystick info
	val = ["{:6.3f}".format(i) for i in j.getAllAxes()]
	buttons = [int(i) for i in j.getAllButtons()]
	print("val: {}, {}".format(val, buttons), end='\r')
	sys.stdout.flush()
