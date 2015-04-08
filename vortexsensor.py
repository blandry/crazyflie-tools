#!/usr/bin/env python2

import u3
import lcm
import math
from crazyflie_t import vortex_sensor_t

VOLTS_TO_PASCAL = 819 # Source: ardupilot AP_Airspeed_analog.cpp
_ratio = 1.9936 # Source: ardupilot AP_Airspeed_analog.cpp
_airspeed0 = 0
_airspeed2 = 0

# Calibrate by taking 2000 measurements and taking simple average
ain0offset = 0
ain2offset = 2


if __name__=="__main__":
    d = u3.U3()
    lc = lcm.LCM()

    for i in range(1,2000):
        ain0bits, = d.getFeedback(u3.AIN(0)) # Read from raw bits from AIN0
        ain0Value = d.binaryToCalibratedAnalogVoltage(ain0bits, isLowVoltage=False, channelNumber=0)
        ain0offset = (ain0offset + ain0value) / i

        ain2bits, = d.getFeedback(u3.AIN(2)) # Read from raw bits from AIN0
        ain2Value = d.binaryToCalibratedAnalogVoltage(ain2bits, isLowVoltage=False, channelNumber=0)
        ain2offset = (ain2offset + ain2value) / i

    try:

        while True:
            msg = vortex_sensor_t()

            ain0bits, = d.getFeedback(u3.AIN(0)) # Read from raw bits from AIN0
            ain0Value = d.binaryToCalibratedAnalogVoltage(ain0bits, isLowVoltage=False, channelNumber=0)
            
            airspeed_pressure0 = (ain0Value - ain0offset)*VOLTS_TO_PASCAL
            raw_pressure0      = airspeed_pressure0
            _raw_airspeed0     = math.sqrt( airspeed_pressure0 * _ratio)
            _airspeed0         = 0.7 * _airspeed0  +  0.3 * _raw_airspeed0;
            msg.sensor1 = _airspeed0

            ain2bits, = d.getFeedback(u3.AIN(2)) # Read from raw bits from AIN2
            ain2Value = d.binaryToCalibratedAnalogVoltage(ain2bits, isLowVoltage=False, channelNumber=2)
            
            airspeed_pressure2 = (ain2Value - ain2offset)*VOLTS_TO_PASCAL
            raw_pressure2      = airspeed_pressure2
            _raw_airspeed2     = math.sqrt( airspeed_pressure2 * _ratio)
            _airspeed2         = 0.7 * _airspeed2  +  0.3 * _raw_airspeed2;
            msg.sensor2 = _airspeed2


            lc.publish('vortex_sensor',msg.encode())







    except KeyboardInterrupt:
        exit(0)