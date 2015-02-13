#!/usr/bin/env python2

import struct
import math
import numpy
import array
import usb
import os
from threading import Thread

import cflib
from cflib.crazyflie import Crazyflie
from cflib.crtp.crtpstack import CRTPPacket, CRTPPort

import lcm
from crazyflie_t import crazyflie_imu_t, crazyflie_input_t

try:
    import usb.core
    pyusb_backend = None
    if os.name == "nt":
        import usb.backend.libusb0 as libusb0
        pyusb_backend = libusb0.get_backend()
    pyusb1 = True
except:
    pyusb1 = False


MODES = {
'32bits':       1,
'omegasqu':     2,
'onboardpd':    3,
}

class LCMChannels:
    IMU = 'crazyflie_imu'
    INPUT = 'crazyflie_input'


RUN_CONTROLLER = False

# NOTE I ZERO THE PROP GAIN
ROLL_KP = 0*3.5*180/math.pi;
PITCH_KP = 0*3.5*180/math.pi;
YAW_KP = 0.0;
ROLL_RATE_KP = 70*180/math.pi;
PITCH_RATE_KP = 70*180/math.pi; 
YAW_RATE_KP = 50*180/math.pi;
K = numpy.matrix([[0,0,0,0,PITCH_KP,YAW_KP,0,0,0,0,PITCH_RATE_KP,YAW_RATE_KP],
                  [0,0,0,ROLL_KP,0,-YAW_KP,0,0,0,ROLL_RATE_KP,0,-YAW_RATE_KP],
                  [0,0,0,0,-PITCH_KP,YAW_KP,0,0,0,0,-PITCH_RATE_KP,YAW_RATE_KP],
                  [0,0,0,-ROLL_KP,0,-YAW_KP,0,0,0,-ROLL_RATE_KP,0,-YAW_RATE_KP]])


class SimpleClient:

    def __init__(self, link_uri):
        self.xhat = numpy.array([0,0,0,0,0,0,0,0,0,0,0,0]).transpose()

        self._cf = Crazyflie()
        self._cf.connected.add_callback(self._connected)
        self._cf.disconnected.add_callback(self._disconnected)
        self._cf.connection_failed.add_callback(self._connection_failed)
        self._cf.connection_lost.add_callback(self._connection_lost)
        self._cf.open_link(link_uri)
        print "Connecting to %s" % link_uri

    def _connected(self, link_uri):        
        self._cf.link.device_flag.clear()
        self._dev_handle = self._cf.link.cradio.handle
        # self._sensors_lc = lcm.LCM()
        Thread(target=self._raw_radio_out).start()
        Thread(target=self._raw_radio_in).start()

    def _raw_radio_out(self):
        _input_lc = lcm.LCM()
        _input_lc.subscribe(LCMChannels.INPUT,self._lcm_to_radio_out)
        while True:
            _input_lc.handle()

    def _lcm_to_radio_out(self, channel, data):
        msg = crazyflie_input_t.decode(data)
        if RUN_CONTROLLER:
            # running the python controller, only use the offset from lcm
            cf_input = self._get_pd_control_input()
            cf_input_offset = msg.offset
            cf_input_type = '32bits'
        else:
            # a controller is hopefully running somewhere else...
            cf_input = msg.input
            cf_input_offset = msg.offset
            cf_input_type = msg.type

        pk = CRTPPacket()
        pk.port = CRTPPort.OFFBOARDCTRL
        pk.data = struct.pack('<5fi',float(cf_input[0]),float(cf_input[1]),float(cf_input[2]),float(cf_input[3]),float(cf_input_offset),MODES.get(cf_input_type,1))
        
        dataOut = array.array('B')
        dataOut.append(pk.header)
        for X in pk.data:
            if type(X) == int:
                dataOut.append(X)
            else:
                dataOut.append(ord(X))
        
        try:
            if (pyusb1 is False):
                self._dev_handle.bulkWrite(1, dataOut, 1)
            else:
                self._dev_handle.write(endpoint=1, data=dataOut, timeout=1)
        except usb.USBError:
            return

        print "-> " + pk.__str__()

        # dataIn = None
        # try:
        #     if (pyusb1 is False):
        #         dataIn = self._dev_handle.bulkRead(0x81, 64, 1)
        #     else:
        #         dataIn = self._dev_handle.read(0x81, 64, timeout=1)
        # except usb.USBError:
        #     return
        # if dataIn is None:
        #     return
        # if dataIn[0] != 0:
        #     data = dataIn[1:]
        # else:
        #     return
        # if (len(data) > 0):
        #     packet = CRTPPacket(data[0], list(data[1:]))
        # else:
        #     return
        # # print "<- " + packet.__str__()
        # sensor_readings = struct.unpack('<6f',packet.data)

        # self._set_sensor_reading(sensor_readings)

        # msg = crazyflie_imu_t()
        # msg.roll = sensor_readings[0]
        # msg.pitch = sensor_readings[1]
        # msg.yaw = sensor_readings[2]
        # msg.rolld = sensor_readings[3]
        # msg.pitchd = sensor_readings[4]
        # msg.yawd = sensor_readings[5]
        # self._sensors_lc.publish(LCMChannels.IMU, msg.encode())

    def _raw_radio_in(self):
        _sensors_lc = lcm.LCM()
        
        while True:
            dataIn = None
            try:
                if (pyusb1 is False):
                    dataIn = self._dev_handle.bulkRead(0x81, 64, 1)
                else:
                    dataIn = self._dev_handle.read(0x81, 64, timeout=1000)
            except usb.USBError:
                continue
            if dataIn is None:
                continue
            if dataIn[0] != 0:
                data = dataIn[1:]
            else:
                continue
            if (len(data) > 0):
                packet = CRTPPacket(data[0], list(data[1:]))
            else:
                continue
            sensor_readings = struct.unpack('<6f',packet.data)
            
            self._set_sensor_reading(sensor_readings)

            print "<- " + packet.__str__()

            msg = crazyflie_imu_t()
            msg.roll = sensor_readings[0]
            msg.pitch = sensor_readings[1]
            msg.yaw = sensor_readings[2]
            msg.rolld = sensor_readings[3]
            msg.pitchd = sensor_readings[4]
            msg.yawd = sensor_readings[5]
            _sensors_lc.publish(LCMChannels.IMU, msg.encode())

    def _set_sensor_reading(self, y):
        """ STATE ESTIMATOR """
        # could do some smoothing here
        alpha = 1
        self.xhat = numpy.dot(1-alpha,self.xhat) + numpy.dot(alpha,numpy.array([0,0,0,y[0],y[1],y[2],0,0,0,y[3],y[4],y[5]]).transpose())

    def _get_pd_control_input(self):
        """ CONTROLLER """
        return (numpy.array(numpy.dot(K,self.xhat))[0]).tolist()

    def _connection_failed(self, link_uri, msg):
        print "Connection to %s failed: %s" % (link_uri, msg)

    def _connection_lost(self, link_uri, msg):
        print "Connection to %s lost: %s" % (link_uri, msg)

    def _disconnected(self, link_uri):
        print "Disconnected from %s" % link_uri


if __name__ == '__main__':
    cflib.crtp.init_drivers(enable_debug_driver=False)
    print "Scanning interfaces for Crazyflies..."
    available = cflib.crtp.scan_interfaces()
    print "Crazyflies found:"
    for i in available:
        print i[0]

    if len(available) > 0:
        client = SimpleClient(available[0][0])
    else:
        print "No Crazyflies found, cannot run the client"