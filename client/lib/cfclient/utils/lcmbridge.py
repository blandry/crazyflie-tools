import lcm
import threading
import struct

from crazyflie_t import crazyflie_thrust_t
from cflib.crtp.crtpstack import CRTPPacket, CRTPPort

class LCMBridge(object):

  def __init__(self,cf,channel):
    self._cf = cf
    self._channel = channel
    self._running = threading.Event()
    self._worker = threading.Thread(target=LCMBridge.bridge_task,args=(self._cf,self._channel,self._running))
    self._worker.start()

  def start(self):
    self._running.set()

  def stop(self):
    self._running.clear()

  def destroy(self):
    # not implemented yet
    pass

  @staticmethod
  def bridge_task(cf,channel,running):
    lc = lcm.LCM()
    subscription = lc.subscribe(channel,lambda _channel,_data: LCMBridge.handle_msg(_channel,_data,cf))
    while True:
      running.wait()
      lc.handle()

  @staticmethod
  def handle_msg(channel,data,cf):
    msg = crazyflie_thrust_t.decode(data)
    pk = CRTPPacket()
    pk.port = CRTPPort.OFFBOARDCTRL
    pk.data = struct.pack('<HHHH', int(msg.thrust1)+32768,int(msg.thrust2)+32768,int(msg.thrust3)+32768,int(msg.thrust4)+32768)
    cf.send_packet(pk)
