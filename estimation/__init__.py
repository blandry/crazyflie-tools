
import time
import lcm
import numpy as np
import MahonyAHRS
from threading import Thread
from crazyflie_t import crazyflie_state_estimate_t, crazyflie_state_estimator_commands_t
from vicon_t import vicon_pos_t
from ukf import UnscentedKalmanFilter
from models import DoubleIntegrator
from transforms import angularvel2rpydot, body2world, quat2rpy, world2body


class StateEstimator():

	def __init__(self, listen_to_vicon=False, publish_to_lcm=False, use_rpydot=False, use_ukf=False):
		
		self._tvlqr_counting = False
		self._last_time_update = time.time()
		self._current_dt = 0.0
		Thread(target=self._estimator_watchdog).start()

		self.q = [1.0, 0.0, 0.0, 0.0] # quaternion of sensor frame relative to auxiliary frame
		self.integralFB = [0.0, 0.0, 0.0] # integral error terms scaled by Ki	
		self._last_rpy = [0.0, 0.0, 0.0]
		self._last_gyro = [0.0, 0.0, 0.0]
		self._last_acc = [0.0, 0.0, 0.0]
		self._last_imu_update = time.time()	

		self._last_xyz = [0.0, 0.0, 0.0]
		self._last_dxyz = [0.0, 0.0, 0.0]
		self._last_vicon_rpy = [0.0, 0.0, 0.0]
		self._last_vicon_update = time.time()
		self._valid_vicon = False
		self._vicon_alpha_pos = .8
		self._vicon_alpha_vel = .7

		self._use_rpydot = use_rpydot
		self._publish_to_lcm = publish_to_lcm
		if publish_to_lcm:
			self._xhat_lc = lcm.LCM()

		self._listen_to_vicon = listen_to_vicon
		if listen_to_vicon:
			Thread(target=self._vicon_listener).start()

		self._last_input = [0.0, 0.0, 0.0, 0.0]
		self._use_ukf = use_ukf
		if use_ukf:
			# (acc in Gs in body frame)
			# states: x y z dx dy dz accxbias accybias acczbias
			# inputs: roll pitch yaw accx accy accz
			# measurements: x y z dx dy dz accxbias accybias acczbias
			self._plant = DoubleIntegrator()
			self._ukf = UnscentedKalmanFilter(dim_x=9, dim_z=9, plant=self._plant)
			self._last_ukf_update = time.time()
			self._last_acc_bias = [0.0, 0.0, 0.0]

	def add_imu_reading(self, imu_reading):
		(gx, gy, gz, ax, ay, az, dt_imu) = imu_reading

		dt = time.time() - self._last_imu_update
		new_quat = MahonyAHRS.MahonyAHRSupdateIMU(gx,gy,gz,ax,ay,az,dt,
												  self.q[0],self.q[1],self.q[2],self.q[3],
												  self.integralFB[0],self.integralFB[0],self.integralFB[0])
		self._last_imu_update = time.time()

		self.q = new_quat[0:4]
		self.integralFB = new_quat[4:]
		try:
			self._last_rpy = quat2rpy(self.q)
		except ValueError:
			pass
		self._last_gyro = [gx,gy,gz]
		self._last_acc = [ax,ay,az]

	def add_input(self, input_sent):
		self._last_input = input_sent

	def _vicon_listener(self):
		_vicon_listener_lc = lcm.LCM()
		_vicon_listener_lc.subscribe('crazyflie2_squ_ext',self._add_vicon_reading)
		while True:
			_vicon_listener_lc.handle()

	def _add_vicon_reading(self, channel, data):
		msg = vicon_pos_t.decode(data)
		
		if msg.q[0] < -999:
			self._valid_vicon = False
			#self._last_dxyz = [0.0, 0.0, 0.0]
			return
		
		xyz = list(msg.q)[0:3]
		dxyz = [0.0, 0.0, 0.0]
		if self._valid_vicon:
			dt = 1.0/120.0
			dt_measured = (msg.timestamp-self._last_vicon_update)/1000.0
			if (dt_measured>1.1*dt):
				dt = dt_measured
			dxyz[0] = (1.0/dt)*(xyz[0]-self._last_xyz[0])
			dxyz[1] = (1.0/dt)*(xyz[1]-self._last_xyz[1])
			dxyz[2] = (1.0/dt)*(xyz[2]-self._last_xyz[2])
		
		self._last_xyz[0] = self._vicon_alpha_pos*xyz[0]+(1-self._vicon_alpha_pos)*self._last_xyz[0]+1
		self._last_xyz[1] = self._vicon_alpha_pos*xyz[1]+(1-self._vicon_alpha_pos)*self._last_xyz[1]
		self._last_xyz[2] = self._vicon_alpha_pos*xyz[2]+(1-self._vicon_alpha_pos)*self._last_xyz[2]
		self._last_dxyz[0] = self._vicon_alpha_vel*dxyz[0]+(1-self._vicon_alpha_vel)*self._last_dxyz[0]
		self._last_dxyz[1] = self._vicon_alpha_vel*dxyz[1]+(1-self._vicon_alpha_vel)*self._last_dxyz[1]
		self._last_dxyz[2] = self._vicon_alpha_vel*dxyz[2]+(1-self._vicon_alpha_vel)*self._last_dxyz[2]
		self._last_vicon_update = msg.timestamp
		self._valid_vicon = True

	def get_xhat(self):
		# should maybe put a lock on those variables before accessing them

		if self._use_ukf:
			dt = time.time() - self._last_ukf_update
			# predict step
			self._ukf.predict(np.array(self._last_rpy + self._last_acc), dt)
			# update step
			residual = self._ukf.update(np.array(self._last_xyz + self._last_dxyz + self._last_acc_bias))
			# use the update error as a 'measurement' of the accelerometer bias
			self._last_acc_bias = world2body(self._last_rpy,np.dot((1.0/(dt*9.81)),residual[3:6])) # measured acc bias (body frame) in Gs			
			self._last_ukf_update = time.time()
			ukf_xhat = self._ukf.x.tolist()
			xhat = [ukf_xhat[0],ukf_xhat[1],ukf_xhat[2],
					self._last_rpy[0],self._last_rpy[1],self._last_rpy[2],
					ukf_xhat[3],ukf_xhat[4],ukf_xhat[5],
					self._last_gyro[0],self._last_gyro[1],self._last_gyro[2]]
		else:
			xhat = [self._last_xyz[0],self._last_xyz[1],self._last_xyz[2],
					self._last_rpy[0],self._last_rpy[1],self._last_rpy[2],
					self._last_dxyz[0],self._last_dxyz[1],self._last_dxyz[2],
					self._last_gyro[0],self._last_gyro[1],self._last_gyro[2]]

		if self._use_rpydot:
			try:
				xhat[9:12] = angularvel2rpydot(self._last_rpy, body2world(self._last_rpy, self._last_gyro))
			except ValueError:
				xhat[9:12] = [0.0, 0.0, 0.0]

		if self._publish_to_lcm:
			msg = crazyflie_state_estimate_t()
			msg.xhat = xhat
			msg.t = self.get_time()
			self._xhat_lc.publish("crazyflie_state_estimate", msg.encode())

		return xhat

	def get_time(self):
		if self._tvlqr_counting:
			self._current_dt += (time.time()-self._last_time_update)
		self._last_time_update = time.time()
		return self._current_dt

	def _estimator_watchdog(self):
		_watchdog_lc = lcm.LCM()
		_watchdog_lc.subscribe('crazyflie_state_estimator_commands',self._estimator_watchdog_update)
		while True:
			_watchdog_lc.handle()

	def _estimator_watchdog_update(self, channel, data):
		msg = crazyflie_state_estimator_commands_t.decode(data)
		self._tvlqr_counting = msg.tvlqr_counting