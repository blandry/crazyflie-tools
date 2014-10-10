#!/bin/bash

lcm-gen -j crazyflie_t.lcm
javac crazyflie_t/*.java
jar cf crazyflie_t.jar crazyflie_t/*.class
rm -rf crazyflie_t
lcm-gen -p crazyflie_t.lcm
