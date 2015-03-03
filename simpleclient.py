#!/usr/bin/env python2


############################ CLIENT OPTIONS ##########################################
TXRX_FREQUENCY = 1000.0
######################################################################################


import struct
import array
import usb
import os
import time
from threading import Thread, Lock, Event

import cflib
from cflib.crazyflie import Crazyflie
from cflib.crtp.crtpstack import CRTPPacket, CRTPPort

from sensorfusion import SensorFusion
from controller import Controller

# Crazyradio options
ACK_ENABLE = 0x10
SET_RADIO_ARC = 0x06
SET_DATA_RATE = 0x03


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
        # stoping the regular crtp link        
        self._cf.link.device_flag.clear()
        self._dev_handle = self._cf.link.cradio.handle
        self._send_vendor_setup(SET_RADIO_ARC, 0, 0, ())

        self._drake_controller = True

        # state estimator
        self._state_estimator = SensorFusion(listen_to_vicon=True,
                                             publish_to_lcm=True,
                                             use_rpydot=False)

        # controller
        self._control_input_updated_flag = Event()
        self._controller = Controller(control_input_type='omegasqu',
                                      listen_to_lcm=True,
                                      control_input_updated_flag=self._control_input_updated_flag,
                                      listen_to_extra_input=True,
                                      publish_to_lcm=False)
        
        # Transmitter thread (handles all comm with the crazyflie)
        Thread(target=self._transmitter_thread).start()

    def _connection_failed(self, link_uri, msg):
        print "Connection to %s failed: %s" % (link_uri, msg)

    def _connection_lost(self, link_uri, msg):
        print "Connection to %s lost: %s" % (link_uri, msg)

    def _disconnected(self, link_uri):
        print "Disconnected from %s" % link_uri

    def _transmitter_thread(self):
        sensor_request_pk = CRTPPacket()
        sensor_request_pk.port = CRTPPort.SENSORS
        sensor_request_pk.data = struct.pack('')
        sensor_request_dataout = self._pk_to_dataout(sensor_request_pk)
        control_input_pk = CRTPPacket()
        control_input_pk.port = CRTPPort.OFFBOARDCTRL
        while True:
            t0 = time.time()

            datain = self._write_read_usb(sensor_request_dataout)
            sensor_packet = self._datain_to_pk(datain)
            if not sensor_packet:
                continue
            try:
                imu_reading = struct.unpack('<7f',sensor_packet.data)
            except:
                continue
            self._state_estimator.add_imu_reading(imu_reading)
            self._control_input_updated_flag.clear()
            xhat = self._state_estimator.get_xhat()
            if self._drake_controller:
                # wait for Drake to give us the control input...
                self._control_input_updated_flag.wait(0.01)

            control_input = self._controller.get_control_input(xhat=xhat)
            control_input_pk.data = struct.pack('<5fi',*control_input)
            control_input_dataout = self._pk_to_dataout(control_input_pk) 
            self._write_usb(control_input_dataout)

            tf = time.time()
            time.sleep(max(0.0,(1.0/TXRX_FREQUENCY)-float(tf-t0)))

    def _pk_to_dataout(self,pk):
        dataOut = array.array('B')
        dataOut.append(pk.header)
        for X in pk.data:
            if type(X) == int:
                dataOut.append(X)
            else:
                dataOut.append(ord(X))
        return dataOut

    def _datain_to_pk(self,dataIn):
        if dataIn != None:
            if dataIn[0] != 0:
                data = dataIn[1:]
                if (len(data) > 0):
                    packet = CRTPPacket(data[0], list(data[1:]))
                    return packet

    def _write_usb(self, dataout):
        try:
            self._dev_handle.write(endpoint=1, data=dataout, timeout=0)
        except usb.USBError:
            pass

    def _write_read_usb(self, dataout):
        datain = None
        try:
            self._dev_handle.write(endpoint=1, data=dataout, timeout=0)
            datain = self._dev_handle.read(0x81, 64, timeout=5)
        except usb.USBError:
            pass
        return datain

    def _send_vendor_setup(self, request, value, index, data):
        self._dev_handle.ctrl_transfer(usb.TYPE_VENDOR, request, wValue=value,
                                        wIndex=index, timeout=1000, data_or_wLength=data)


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