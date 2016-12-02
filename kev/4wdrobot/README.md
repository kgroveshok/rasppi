4WD Robot
---------


Robot Hardware:

*  4init 4wd bot base - add link
*  sharp ir sensor - link 
*  ultrasonic sensor - link
*  pan/tilt arm (2 x servo) -link 
*  usb webcam mounted on continuois servo (becase lacking a 180deg servo)
*  piconzero controller - link
*    motors connected h-bridge
*    ultrasonic on deadicated connection
*    ir on input pin 3
*    wheel rotation counters on pins 0 and 1
*    arm pan/tilt on output 0 and 1
*    webcam server on output 2

Software:
*  python
*  opencv/simplecv
*  motion (with single image and video streaming)
*  piconzero requirements for i2c
*  lighttpd for access to motion/opencv image processing

Installation
apt-get install python-zbar
    1  apt-get install ssh
    2  sudo apt-get install ssh
    3  sudo apt-get install openssh-server
   18  sudo apt-get install python-smbus python3-smbus python-dev python3-dev
   25  i2cdetect -y 1
   26  sudo halt -p
   27  i2cdetect -y 1
   28  dmesg |less
   29  cat /boot/config.txt 
   30  dmesg |less
   31  i2cdetect -y 1
   32  i2cdetect 
   33  i2cdetect -l
   34  i2cdetect -y 
   35  i2cdetect -y 1
   36  sudo halt -p
   37  i2cdetect -y 1
   38  wget http://4tronix.co.uk/piconz.sh -O piconz.sh
   39  bash piconz.sh 
   58  sudo apt-get install dnsmasq hostapd 
   59  sudo nano /etc/network/interfaces
   63  sudo service dhcpcd  restart
   64  ifconfig
   65  sudo ifdown wlan0
   66  sudo ifup wlan0
   67  ifconfig
   68  sudo nano /etc/hostapd/hostapd.conf
   69  sudo servuce hostapd start
   70  sudo service hostapd start
   71  sudo nano /etc/default/hostapd 
   72  cd /etc/
   73  sudo mv dnsmasq.conf{.was}
   74  sudo mv dnsmasq.conf dnsmasq.conf.was
   75  sudo nano dnsmasq.conf 
   76  sudo nano /etc/sysctl.conf 
   77  sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE  
   78  sudo iptables -A FORWARD -i eth0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT  
   79  sudo iptables -A FORWARD -i wlan0 -o eth0 -j ACCEPT  
   80  sudo sh -c "iptables-save > /etc/iptables.ipv4.nat"
   81  sudo nano /etc/rc.local 
   82  sudo service hostapd restart
   83  sudo service dnsmasq restart
  100  sudo apt-get install motion
  219  audo apt-get update
  220  sudo apt-get update
  221  sudo apt-get install motion
  222  nano /etc/motion/motion.conf 
  223  sudo nano /etc/motion/motion.conf 
  650  sudo apt-get install lighttpd
  651  ls
  652  cd /var/www/
  653  ls
  654  cd html/
  655  ls
  656  ls -la
  657  mv index.lighttpd.html{,.was}
  658  ls
  659  sudo mv index.lighttpd.html{,.was}
  660  sudo vim index.html
  661  ln -s /dev/shm/lastsnap.jpg webcam.jpg
  662  sudo ln -s /dev/shm/lastsnap.jpg webcam.jpg
  677  sudo apt-get install python-opencv
  683  pip install https://github.com/sightmachine/SimpleCV/zipball/master
  684  sudo pip install https://github.com/sightmachine/SimpleCV/zipball/master
  688  sudo apt-get install python-scipy
  692  sudo pip install svgwrite
  703  sudo ln -s /dev/shm/p3.png /var/www/html/p3.png
  704  sudo ln -s /dev/shm/p4.png /var/www/html/p4.png
  719  wget https://github.com/sightmachine/SimpleCV/zipball/master
  805  update-rc.d motion
  806  update-rc.d motion enable
  807  sudo update-rc.d motion enable
  824  sudo update-rc.d motion enable 235


* Todo

1. Avoidance testing
2. Increase framerate of motion and add convert images via opencv outside the main program
3. Move ir sensor to direct gpio and so free up piconzero for the additional second set of wheel counters
4. Add photos of bot with close ups
5. Include use of Kinetic to improve the depth and shape detection
	(No as it requires a 12v supply. Not handy in this robot)
6. Change of IR to front so now need auto stop if too close. Do an ultrasonic scan and test if obstruction is moving or stationary
7. If stationary then need to move around it. If its moving then wait it out.
8. Include voice recgnition via alexa https://github.com/alexa/alexa-avs-sample-app/wiki/Raspberry-Pi
9. http://lifehacker.com/how-to-build-your-own-amazon-echo-with-a-raspberry-pi-1787726931
