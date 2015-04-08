#!/usr/bin/env python2

import u3
import lcm
from crazyflie_t import vortex_sensor_t

if __name__=="__main__":
    d = u3.U3()
    lc = lcm.LCM()

    try:

        while True:
            msg = vortex_sensor_t()

            ain0bits, = d.getFeedback(u3.AIN(0)) # Read from raw bits from AIN0
            ain0Value = d.binaryToCalibratedAnalogVoltage(ain0bits, isLowVoltage=False, channelNumber=0)
            msg.sensor1 = ain0Value

            ain2bits, = d.getFeedback(u3.AIN(2)) # Read from raw bits from AIN2
            ain2Value = d.binaryToCalibratedAnalogVoltage(ain2bits, isLowVoltage=False, channelNumber=2)
            msg.sensor2 = ain2Value

            lc.publish('vortex_sensor',msg.encode())

    except KeyboardInterrupt:
        exit(0)