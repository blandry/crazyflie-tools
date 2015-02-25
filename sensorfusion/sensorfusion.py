
import MahonyAHRS
from math import atan2, asin


class SensorFusion():

	def __init__(self):
		self.q = [1.0, 0.0, 0.0, 0.0] # quaternion of sensor frame relative to auxiliary frame
		self.integralFB = [0.0, 0.0, 0.0] # integral error terms scaled by Ki
		self._rpy = [0.0, 0.0, 0.0]

	def update_q(self, gx, gy, gz, ax, ay, az, dt):
		new_vals = MahonyAHRS.MahonyAHRSupdateIMU(gx,gy,gz,ax,ay,az,dt,
												  self.q[0],self.q[1],self.q[2],self.q[3],
												  self.integralFB[0],self.integralFB[0],self.integralFB[0])
		self.q = new_vals[0:4]
		self.integralFB = new_vals[4:]

	def get_rpy(self):
		try:
			new_rpy = quat2rpy(self.q)
		except ValueError:
			new_rpy = self._rpy

		self._rpy = new_rpy
		return self._rpy


def quat2rpy(q):
	q_norm = (q[0]**2+q[1]**2+q[2]**2+q[3]**2)
	q = [q_i/q_norm for q_i in q]
	w = q[0]
	x = q[1]
	y = q[2]
	z = q[3]
	rpy = [atan2(2*(w*x + y*z), w*w + z*z - (x*x + y*y)),
  		   asin(2*(w*y - z*x)),
           atan2(2*(w*z + x*y), w*w + x*x - (y*y + z*z))]
	return rpy