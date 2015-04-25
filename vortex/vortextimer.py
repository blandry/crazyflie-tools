#!/usr/bin/env python2

import lcm
import math
from crazyflie_t import vortex_sensor_t
import time

class VortexSensor():

  def __init__(self):
    self.lookingforvortex = False
    self.start = time.time()
    self.sensordistance = 0.58 # 58 cm measured between sensors
    self.waittime = 4 # seconds to wait before giving up looking for vortex ring at rear sensor
    self.threshold = 5 # threshold for pitot sensor, in m/s

  def my_handler(self, channel, data):
    msg = vortex_sensor_t.decode(data)
    
    # Print statements for receiving messages

    #print("Received message on channel \"%s\"" % channel)
    #print("   sensor1   = %s" % str(msg.sensor1))
    #print("   sensor2    = %s" % str(msg.sensor2))
    #print("")

    # Sensor 2 is up front
    if msg.sensor2 > self.threshold and not self.lookingforvortex:
      print("She's a beauty!  Vortex at the front sensor!")
      self.start = time.time()
      self.lookingforvortex = True

    if self.lookingforvortex:
      delay = time.time() - self.start      
      if delay > self.waittime:
        self.lookingforvortex = False
        print("Gave up looking for that one...")
      elif msg.sensor1 > self.threshold:
        print("She's at the rear now!")
        delay = time.time() - self.start
        print("That took " + str(delay) + " seconds!")
        speed = self.sensordistance / delay
        print("Estimated vortex speed is " + str(speed) + " meters / sec!")
        msg.velocity = speed
        lc.publish('vortex_sensor',msg.encode())
        self.lookingforvortex = False

if __name__=="__main__":

  print("Looking for vortexes!")

  lc = lcm.LCM()
  sensor = VortexSensor()
  subscription = lc.subscribe("vortex_sensor", sensor.my_handler)

  try:

    while True:
      lc.handle()
          
  except KeyboardInterrupt:
    exit(0)

  lc.unsubscribe(subscription)