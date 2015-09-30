import lcm
import math
from crazyflie_t import webcam_pos_t
import time

if __name__=="__main__":

	lc = lcm.LCM()


    try:

        while True:

            msg = webcam_pos_t()

            msg.x = webcam_x
            msg.y = webcam_y
            msg.z = webcam_z

            msg.timestamp = time.time()

            lc.publish('webcam_pos',msg.encode())


    except KeyboardInterrupt:
        exit(0)