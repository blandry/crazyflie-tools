#!/usr/bin/env python2

import struct
import math
from math import cos, sin
import numpy as np
import array
import usb
import os
from threading import Thread, Lock

import cflib
from cflib.crazyflie import Crazyflie
from cflib.crtp.crtpstack import CRTPPacket, CRTPPort

import lcm
from crazyflie_t import crazyflie_imu_t, crazyflie_input_t, crazyflie_state_estimate_t
from vicon_t import vicon_pos_t

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
    VICON = 'crazyflie2_squ_ext'
    OFFSET = 'crazyflie_extra_offset'
    ESTIMATES = 'crazyflie_state_estimate'


RUN_CONTROLLER = False
HAS_VICON = True

ROLL_KP = .5*3.5*180/math.pi
PITCH_KP = .5*3.5*180/math.pi
YAW_KP = .5*3.5*180/math.pi
ROLL_RATE_KP = .5*70*180/math.pi
PITCH_RATE_KP = .5*70*180/math.pi
YAW_RATE_KP = .5*50*180/math.pi

Z_KP = 0
Z_RATE_KP = 10000

K = np.matrix([[0,0,-Z_KP,0,PITCH_KP,YAW_KP,0,0,-Z_RATE_KP,0,PITCH_RATE_KP,YAW_RATE_KP],
               [0,0,-Z_KP,ROLL_KP,0,-YAW_KP,0,0,-Z_RATE_KP,ROLL_RATE_KP,0,-YAW_RATE_KP],
               [0,0,-Z_KP,0,-PITCH_KP,YAW_KP,0,0,-Z_RATE_KP,0,-PITCH_RATE_KP,YAW_RATE_KP],
               [0,0,-Z_KP,-ROLL_KP,0,-YAW_KP,0,0,-Z_RATE_KP,-ROLL_RATE_KP,0,-YAW_RATE_KP]])


class SimpleClient:

    def __init__(self, link_uri):
        self.xhat = np.array([0,0,0,0,0,0,0,0,0,0,0,0]).transpose()
        self._state_lock = Lock()
        self._state_lc = lcm.LCM()

        self._extra_offset = 0

        self._cf = Crazyflie()
        self._cf.connected.add_callback(self._connected)
        self._cf.disconnected.add_callback(self._disconnected)
        self._cf.connection_failed.add_callback(self._connection_failed)
        self._cf.connection_lost.add_callback(self._connection_lost)
        self._cf.open_link(link_uri)
        print "Connecting to %s" % link_uri

    def _connected(self, link_uri):
        # stoping the regular crtp link        
        self._cf.link.device_flag.clear()
        self._dev_handle = self._cf.link.cradio.handle
        
        # forward crazyflie_input channel to the crazyflie
        Thread(target=self._raw_radio_out).start()

        # gets the imu data back
        Thread(target=self._raw_radio_in).start()

        if HAS_VICON:
            # gets the vicon readings
            Thread(target=self._vicon_in).start()

        # you can publish to crazyflie_extra_offset to
        # add an offset to the thrust (with a remote for example)
        Thread(target=self._offset_only).start()

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
            cf_offset = msg.offset + self._extra_offset
            cf_input_type = '32bits'
        else:
            # a controller is hopefully running somewhere else...
            cf_input = msg.input
            cf_offset = msg.offset + self._extra_offset
            cf_input_type = msg.type

        pk = CRTPPacket()
        pk.port = CRTPPort.OFFBOARDCTRL
        pk.data = struct.pack('<5fi',float(cf_input[0]),float(cf_input[1]),float(cf_input[2]),float(cf_input[3]),float(cf_offset),MODES.get(cf_input_type,1))

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

        # print "-> " + pk.__str__()

    def _raw_radio_in(self):
        _sensors_lc = lcm.LCM()
        
        while True:
            dataIn = None
            try:
                if (pyusb1 is False):
                    dataIn = self._dev_handle.bulkRead(0x81, 64, 1)
                else:
                    dataIn = self._dev_handle.read(0x81, 64, timeout=5000)
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
            try:
                imu_readings = struct.unpack('<7f',packet.data)
            except:
                continue

            self._add_sensor_reading(imu_readings,'imu')

            msg = crazyflie_imu_t()
            msg.roll = imu_readings[0]
            msg.pitch = imu_readings[1]
            msg.yaw = imu_readings[2]
            msg.rolld = imu_readings[3]
            msg.pitchd = imu_readings[4]
            msg.yawd = imu_readings[5]
            _sensors_lc.publish(LCMChannels.IMU, msg.encode())

            # print "<- " + packet.__str__()

    def _vicon_in(self):
        _vicon_lc = lcm.LCM()
        _vicon_lc.subscribe(LCMChannels.VICON,self._vicon_to_state)
        self._last_vicon_q = None
        self._last_timestamp = None
        while True:
            _vicon_lc.handle()

    def _vicon_to_state(self, channel, data):
        msg = vicon_pos_t.decode(data)
        if msg.q[0] < -999:
            self._last_vicon_q = None
            return

        y = list(msg.q)
        
        # nominal z is 1 meter above ground
        y[2] -= 1

        if self._last_vicon_q:
            # could use the timestamp instead of vicon's frequency
            dt = 1.0/120.0
            dt_measured = (msg.timestamp-self._last_timestamp)/1000.0
            if (dt_measured>1.2*dt):
                dt = dt_measured
            y.extend(np.dot(1.0/dt,np.array(msg.q)-np.array(self._last_vicon_q)).tolist())
        else:
            y.extend([0,0,0,0,0,0])
        self._last_vicon_q = list(msg.q)
        self._last_timestamp = msg.timestamp

        self._add_sensor_reading(y, 'vicon')

    def _offset_only(self):
        _offset_lc = lcm.LCM()
        _offset_lc.subscribe(LCMChannels.OFFSET,self._update_offset)
        while True:
            _offset_lc.handle()

    def _update_offset(self, channel, data):
        msg = crazyflie_input_t.decode(data)
        self._extra_offset = msg.offset

    def _add_sensor_reading(self, y, type):
        """ STATE ESTIMATOR """
        self._state_lock.acquire()
        
        if type=='imu':
            dt = y[6]/1000.0            
            y = [self.xhat[0],
                 self.xhat[1],
                 self.xhat[2],
                 self.xhat[3]+self.xhat[9]*dt,
                 self.xhat[4]+self.xhat[10]*dt,
                 self.xhat[5]+self.xhat[11]*dt,
                 self.xhat[6],
                 self.xhat[7],
                 self.xhat[8],
                 y[0],
                 y[1],
                 y[2]]
            alpha = 0.8
            self.xhat = np.dot(1-alpha,self.xhat) + np.dot(alpha,np.array(y).transpose())
        
        elif type=='vicon':
            y = [y[0],
                 y[1],
                 y[2],
                 self.xhat[3],
                 self.xhat[4],
                 self.xhat[5],
                 y[6],
                 y[7],
                 y[8],
                 self.xhat[9],
                 self.xhat[10],
                 self.xhat[11]]
            alpha = 0.8
            self.xhat = np.dot(1-alpha,self.xhat) + np.dot(alpha,np.array(y).transpose())
        
        else:
            pass
        
        self._state_lock.release()
        msg = crazyflie_state_estimate_t()
        msg.xhat = self.xhat.tolist()
        self._state_lc.publish(LCMChannels.ESTIMATES, msg.encode())

    def _get_pd_control_input(self):
        """ CONTROLLER """
        return (np.array(np.dot(K,self.xhat))[0]).tolist()

    def _connection_failed(self, link_uri, msg):
        print "Connection to %s failed: %s" % (link_uri, msg)

    def _connection_lost(self, link_uri, msg):
        print "Connection to %s lost: %s" % (link_uri, msg)

    def _disconnected(self, link_uri):
        print "Disconnected from %s" % link_uri


def rotx(theta):
    c = cos(theta)
    s = sin(theta)
    M = np.matrix([[1,0,0],[0,c,-s],[0,s,c]])
    return M

def roty(theta):
    c = cos(-theta)
    s = sin(-theta)
    M = np.matrix([[c,0,-s],[0,1,0],[s,0,c]])
    return M

def rotz(theta):
    c = cos(theta)
    s = sin(theta)
    M = np.matrix([[c,-s,0],[s,c,0],[0,0,1]])
    return M

def rpy2rotmat(rpy):
    R = np.dot(rotz(rpy[2]),np.dot(roty(rpy[1]),rotx(rpy[0])))
    return R

def body2world(xyz, rpy):
    R = rpy2rotmat(rpy)
    xyz_world = np.dot(np.linalg.inv(R),np.array(xyz).transpose())
    return (np.array(xyz_world)[0]).tolist()


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