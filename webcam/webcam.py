import lcm
import math
from crazyflie_t import webcam_pos_t
import time

if __name__=="__main__":
    lc = lcm.LCM()
    while True:
        msg = webcam_pos_t()

        msg.x = 0;webcam_x
        msg.y = 0;webcam_y
        msg.z = 0;webcam_z

        msg.timestamp = time.time()

        lc.publish('webcam_pos',msg.encode())