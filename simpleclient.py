#!/usr/bin/env python2

import struct
from threading import Thread

import cflib
from cflib.crazyflie import Crazyflie
from cflib.crtp.crtpstack import CRTPPacket, CRTPPort

import lcm
from crazyflie_t import crazyflie_imu_t, crazyflie_input_t

MODES = {
        '32bits':1,
        'omegasqu':2,
        }

class LCMChannels:
    IMU = "crazyflie_imu"
    INPUT = "crazyflie_input"

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
        self._lc = lcm.LCM()
        self._cf.add_port_callback(CRTPPort.SENSORS, self._new_sensor_data)
        Thread(target=self._forward_inputs).start()

    def _connection_failed(self, link_uri, msg):
        print "Connection to %s failed: %s" % (link_uri, msg)

    def _connection_lost(self, link_uri, msg):
        print "Connection to %s lost: %s" % (link_uri, msg)

    def _disconnected(self, link_uri):
        print "Disconnected from %s" % link_uri

    def _new_sensor_data(self, packet):
        data = struct.unpack('<6f',packet.data)
        msg = crazyflie_imu_t()
        msg.roll = data[0]
        msg.pitch = data[1]
        msg.yaw = data[2]
        msg.rolld = data[3]
        msg.pitchd = data[4]
        msg.yawd = data[5]
        self._lc.publish("crazyflie_imu", msg.encode())

    def _forward_inputs(self):
        lc = lcm.LCM()
        subscription = lc.subscribe(LCMChannels.INPUT,lambda _channel,_data: SimpleClient.handle_input(_channel,_data,self._cf))
        while True:
            lc.handle()

    @staticmethod
    def handle_input(channel, data, cf):
        msg = crazyflie_input_t.decode(data)
        pk = CRTPPacket()
        pk.port = CRTPPort.OFFBOARDCTRL
        pk.data = struct.pack('<4fi',float(msg.input[0]),float(msg.input[1]),float(msg.input[2]),float(msg.input[3]),MODES.get(msg.type,1))
        cf.send_packet(pk)

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