from picamera import PiCamera
from time import sleep
import sys
import select
import tty
import termios


def GetChar(Block=True):

#    return raw_input(":")
#
#
    if select.select([sys.stdin], [], [], 0) == ([sys.stdin], [], []):
        return sys.stdin.read(1)
    return '0'


camera = PiCamera()    
camera.resolution = (800, 480)
num=0
camera.start_preview()
while True:
     camera.capture('/var/www/html/astro.jpg')
     sleep(2)
     print "."
     a = GetChar(False)
     if a != '0':
        camera.stop_preview()
        print "Record burst"
        camera.resolution = (3240,2464)
        camera.start_preview()
        for i in range(5):
            camera.capture('/var/www/html/astro%s.jpg' % num)
            print num
            num = num + 1
            sleep(1)
        camera.stop_preview()    
        camera.resolution = (800, 480)
        camera.start_preview()



