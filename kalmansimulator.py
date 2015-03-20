#!/usr/bin/env python2

import lcm
import numpy as np
import random
from estimation.ekf import ExtendedKalmanFilter
from estimation.models import DoubleIntegrator
from crazyflie_t import kalman_args_t, kalman_out_t

class Simulator():

	def __init__(self):	
		self.plant = DoubleIntegrator()
		# states: x y z dx dy dz accxbias accybias acczbias
		# inputs: roll pitch yaw accx accy accz
		# measurements: x y z
		self.kalman = ExtendedKalmanFilter(dim_x=9, dim_z=3, plant=self.plant)
		self.lc = lcm.LCM()
		self.max_blackout = 20
		self.min_blackout = 5
		self.blackout_prob = 0 #.1
		self.current_blackout_count = 0

	def run(self):
		self.lc.subscribe('kalman_args',self.handle_kalman_args)
		while True:
			self.lc.handle()

	def handle_kalman_args(self,channel,data):
		msg = kalman_args_t.decode(data)

		if random.random()<self.blackout_prob and self.current_blackout_count==0:
			self.current_blackout_count = int(random.random()*(self.max_blackout-self.min_blackout)+self.min_blackout)

		if self.current_blackout_count>0:
			self.current_blackout_count -= 1
			msg.valid_vicon = False

		self.kalman.predict(np.array(msg.input_rpy + msg.input_acc), msg.input_dt)
		if msg.valid_vicon:
			self.kalman.update(np.array(msg.meas_xyz))
		kalman_xhat = self.kalman.x.reshape(9).tolist()

		msg_out = kalman_out_t()
		msg_out.kalman_xyz = kalman_xhat[0:3]
		msg_out.kalman_dxyz = kalman_xhat[3:6]
		if msg.valid_vicon:
			msg_out.smooth_xyz = msg.smooth_xyz
			msg_out.smooth_dxyz = msg.smooth_dxyz
		msg_out.smooth_xyz_noblackout = msg.smooth_xyz
		msg_out.smooth_dxyz_noblackout = msg.smooth_dxyz
		self.lc.publish('kalman_out', msg_out.encode())

if __name__=="__main__":
	sim = Simulator()
	sim.run()
