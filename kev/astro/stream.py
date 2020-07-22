from picamera import PiCamera
from time import sleep

camera = PiCamera()    
camera.resolution = (800, 480)
num=0
camera.start_preview()
while True:
        camera.capture('/var/www/html/astro.jpg')
        sleep(2)
