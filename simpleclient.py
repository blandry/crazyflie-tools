#!/usr/bin/env python2

import struct
import math
import numpy
from threading import Thread

import cflib
from cflib.crazyflie import Crazyflie
from cflib.crtp.crtpstack import CRTPPacket, CRTPPort

import lcm
from crazyflie_t import crazyflie_imu_t, crazyflie_input_t

MODES = {
            '32bits':       1,
            'omegasqu':     2,
            'onboardpd':    3,
        }

class LCMChannels:
    IMU = 'crazyflie_imu'
    INPUT = 'crazyflie_input'


class SimpleClient:

    def __init__(self, link_uri):
        self._cf = Crazyflie()
        self._cf.connected.add_callback(self._connected)
        self._cf.disconnected.add_callback(self._disconnected)
        self._cf.connection_failed.add_callback(self._connection_failed)
        self._cf.connection_lost.add_callback(self._connection_lost)
        self._cf.open_link(link_uri)
        print "Connecting to %s" % link_uri

    def _connected(self, link_uri):

        self._sensors_lc = lcm.LCM()
        self._cf.add_port_callback(CRTPPort.SENSORS, self._new_sensor_data)
        
        Thread(target=self._forward_inputs).start()

    def _new_sensor_data(self, packet):
        data = struct.unpack('<6f',packet.data)
        msg = crazyflie_imu_t()
        msg.roll = data[0]
        msg.pitch = data[1]
        msg.yaw = data[2]
        msg.rolld = data[3]
        msg.pitchd = data[4]
        msg.yawd = data[5]
        self._sensors_lc.publish(LCMChannels.IMU, msg.encode())

        # For debugging only PD offboard here
        # x = [0,0,0,data[0],data[1],data[2],0,0,0,data[3],data[4],data[5]]
        # print("State: %s" % x)
        # u = self.get_pd_control_input(x)
        # print("Input: %s" % u)
        # pk = CRTPPacket()
        # pk.port = CRTPPort.OFFBOARDCTRL
        # pk.data = struct.pack('<5fi',u[0],u[1],u[2],u[3],0,MODES.get('32bits',1))
        # self._cf.send_packet(pk)

    def _forward_inputs(self):
        _input_lc = lcm.LCM()
        _input_lc.subscribe(LCMChannels.INPUT,lambda _channel,_data: SimpleClient.handle_input(_channel,_data,self._cf))
        while True:
            _input_lc.handle()

    @staticmethod
    def handle_input(channel, data, cf):
        msg = crazyflie_input_t.decode(data)
        pk = CRTPPacket()
        pk.port = CRTPPort.OFFBOARDCTRL
        pk.data = struct.pack('<5fi',float(msg.input[0]),float(msg.input[1]),float(msg.input[2]),float(msg.input[3]),float(msg.offset),MODES.get(msg.type,1))
        cf.send_packet(pk)

    def get_pd_control_input(self, x):
        x0 = numpy.array([0,0,0,0,0,0,0,0,0,0,0,0])
        u0 = numpy.array([43000,43000,43000,43000])
        ROLL_KP = 3.5*180/math.pi;
        PITCH_KP = 3.5*180/math.pi;
        YAW_KP = 0.0;
        ROLL_RATE_KP = 70*180/math.pi;
        PITCH_RATE_KP = 70*180/math.pi; 
        YAW_RATE_KP = 50*180/math.pi;
        K = numpy.matrix([[0,0,0,0,PITCH_KP,YAW_KP,0,0,0,0,PITCH_RATE_KP,YAW_RATE_KP],
                          [0,0,0,ROLL_KP,0,-YAW_KP,0,0,0,ROLL_RATE_KP,0,-YAW_RATE_KP],
                          [0,0,0,0,-PITCH_KP,YAW_KP,0,0,0,0,-PITCH_RATE_KP,YAW_RATE_KP],
                          [0,0,0,-ROLL_KP,0,-YAW_KP,0,0,0,-ROLL_RATE_KP,0,-YAW_RATE_KP]])
        u = numpy.dot(K,numpy.array(x).transpose()-x0.transpose())
        u = (numpy.array(u)[0]+u0).tolist()
        return u

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
        le = SimpleClient(available[0][0])
    else:
        print "No Crazyflies found, cannot run the client"