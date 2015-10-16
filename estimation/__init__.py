
import time
import lcm
import numpy as np
import MahonyAHRS
from Queue import Queue
from threading import Thread
from crazyflie_t import crazyflie_state_estimate_t, crazyflie_state_estimator_commands_t, dxyz_compare_t, kalman_args_t, crazyflie_hover_commands_t, webcam_pos_t
from vicon_t import vicon_pos_t
from ukf import UnscentedKalmanFilter
from ekf import ExtendedKalmanFilter
from models import DoubleIntegrator, Crazyflie2
from transforms import angularvel2rpydot, body2world, quat2rpy, world2body


class StateEstimator():

	def __init__(self, listen_to_vicon=False, publish_to_lcm=False, 
				 use_rpydot=False, use_ekf=False, use_ukf=False,
				 delay_comp=False, listen_to_webcam=True):
		
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
		self._last_xyz_raw = [0.0, 0.0, 0.0]
		self._last_dxyz = [0.0, 0.0, 0.0]
		self._last_vicon_rpy = [0.0, 0.0, 0.0]
		self._last_vicon_update = time.time()
		self._valid_vicon = False
		self._vicon_alpha_pos = .8
		self._vicon_alpha_vel = .7
		self._vicon_init_yaw = None

		self._use_rpydot = use_rpydot
		self._publish_to_lcm = publish_to_lcm
		if publish_to_lcm:
			self._xhat_lc = lcm.LCM()

		#self._listen_to_vicon = listen_to_vicon            # Commented out for now
		#if listen_to_vicon:
		#	Thread(target=self._vicon_listener).start()
		if listen_to_webcam:
			Thread(target=self._webcam_listener).start()

		self._input_log = list()
		self._last_input = [0.0, 0.0, 0.0, 0.0]
		self._last_input_time = time.time()
		self._delay_comp = delay_comp
		if delay_comp:
			self._cf_model = Crazyflie2()
			self._delay = 0.028 # delay in the control loop in seconds

		self._use_ekf = use_ekf
		self._use_ukf = use_ukf
		self._use_kalman = use_ekf or use_ukf
		if self._use_kalman:
			# states: x y z dx dy dz accxbias accybias acczbias
			# inputs: roll pitch yaw accx accy accz
			# measurements: x y z
			self._plant = DoubleIntegrator()
			self._last_kalman_update = time.time()
			if use_ekf:
				self._kalman = ExtendedKalmanFilter(dim_x=9, dim_z=3, plant=self._plant)
			elif use_ukf:
				self._kalman = UnscentedKalmanFilter(dim_x=9, dim_z=3, plant=self._plant)

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
			if self._vicon_init_yaw:
				self._last_rpy[2] += self._vicon_init_yaw
		except ValueError:
			pass
		self._last_gyro = [gx,gy,gz]
		self._last_acc = [ax,ay,az]

	def add_input(self, input_sent):
		last_dt = time.time()-self._last_input_time
		self._input_log.append([self._last_input,last_dt])		
		if len(self._input_log)>20:
			self._input_log = self._input_log[10:]
		self._last_input = input_sent
		self._last_input_time = time.time()

	def get_last_inputs(self, tspan):
		control_inputs = list()
		log = list(self._input_log)
		dt = 0.0
		for entry in log:
			dt += entry[1]
			if dt>tspan:
				break
			control_inputs.insert(0,entry)
		if len(control_inputs)<1:
			control_inputs = [[[0.0, 0.0, 0.0, 0.0],tspan]]
		return control_inputs


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
		
		if not self._vicon_init_yaw:
			self._vicon_init_yaw = msg.q[5]

		xyz = list(msg.q)[0:3]
		dxyz = [0.0, 0.0, 0.0]
		if self._valid_vicon:
			dt = 1.0/120.0
			dt_measured = (msg.timestamp-self._last_vicon_update)/1000.0
			if (dt_measured>1.5*dt):
				dt = dt_measured
			dxyz[0] = (1.0/dt)*(xyz[0]-self._last_xyz_raw[0])
			dxyz[1] = (1.0/dt)*(xyz[1]-self._last_xyz_raw[1])
			dxyz[2] = (1.0/dt)*(xyz[2]-self._last_xyz_raw[2])
			self._last_xyz_raw = list(xyz)
		
		self._last_xyz[0] = self._vicon_alpha_pos*xyz[0]+(1-self._vicon_alpha_pos)*self._last_xyz[0]
		self._last_xyz[1] = self._vicon_alpha_pos*xyz[1]+(1-self._vicon_alpha_pos)*self._last_xyz[1]
		self._last_xyz[2] = self._vicon_alpha_pos*xyz[2]+(1-self._vicon_alpha_pos)*self._last_xyz[2]
		self._last_dxyz[0] = self._vicon_alpha_vel*dxyz[0]+(1-self._vicon_alpha_vel)*self._last_dxyz[0]
		self._last_dxyz[1] = self._vicon_alpha_vel*dxyz[1]+(1-self._vicon_alpha_vel)*self._last_dxyz[1]
		self._last_dxyz[2] = self._vicon_alpha_vel*dxyz[2]+(1-self._vicon_alpha_vel)*self._last_dxyz[2]
		self._last_vicon_update = msg.timestamp
		self._valid_vicon = True


	def _webcam_listener(self):
		_webcam_listener_lc = lcm.LCM()
		_webcam_listener_lc.subscribe('WEBCAM_POS',self._add_webcam_reading)
		while True:
			_webcam_listener_lc.handle()

	def _add_webcam_reading(self, channel, data):
		msg = webcam_pos_t.decode(data)
		
		if msg.frame_id == -1:
			self._valid_vicon = False
			#self._last_dxyz = [0.0, 0.0, 0.0]
			return
		
		if not self._vicon_init_yaw:
			self._vicon_init_yaw = msg.yaw

		xyz = [msg.x, msg.y, msg.z]
		dxyz = [0.0, 0.0, 0.0]
		if self._valid_vicon:
			dt = 1.0/120.0
			dt_measured = (msg.timestamp-self._last_vicon_update)/1000.0
			if (dt_measured>1.5*dt):
				dt = dt_measured
			dxyz[0] = (1.0/dt)*(xyz[0]-self._last_xyz_raw[0])
			dxyz[1] = (1.0/dt)*(xyz[1]-self._last_xyz_raw[1])
			dxyz[2] = (1.0/dt)*(xyz[2]-self._last_xyz_raw[2])
			self._last_xyz_raw = list(xyz)
		
		self._last_xyz[0] = self._vicon_alpha_pos*xyz[0]+(1-self._vicon_alpha_pos)*self._last_xyz[0]
		self._last_xyz[1] = self._vicon_alpha_pos*xyz[1]+(1-self._vicon_alpha_pos)*self._last_xyz[1]
		self._last_xyz[2] = self._vicon_alpha_pos*xyz[2]+(1-self._vicon_alpha_pos)*self._last_xyz[2]
		self._last_dxyz[0] = self._vicon_alpha_vel*dxyz[0]+(1-self._vicon_alpha_vel)*self._last_dxyz[0]
		self._last_dxyz[1] = self._vicon_alpha_vel*dxyz[1]+(1-self._vicon_alpha_vel)*self._last_dxyz[1]
		self._last_dxyz[2] = self._vicon_alpha_vel*dxyz[2]+(1-self._vicon_alpha_vel)*self._last_dxyz[2]
		self._last_vicon_update = msg.timestamp
		self._valid_vicon = True

	def get_xhat(self):
		if self._use_kalman:
			dt = time.time() - self._last_kalman_update
			self._kalman.predict(np.array(self._last_rpy + self._last_acc), dt)
			if self._valid_vicon:
				self._kalman.update(np.array(self._last_xyz))
			self._last_kalman_update = time.time()
			kalman_xhat = self._kalman.x.reshape(9).tolist()
			xhat = [kalman_xhat[0],kalman_xhat[1],kalman_xhat[2],
					self._last_rpy[0],self._last_rpy[1],self._last_rpy[2],
					kalman_xhat[3],kalman_xhat[4],kalman_xhat[5],
					self._last_gyro[0],self._last_gyro[1],self._last_gyro[2]]

			# msg = dxyz_compare_t()
			# msg.dxyzraw = self._last_dxyz
			# msg.dxyzfiltered = kalman_xhat[3:6]
			# self._xhat_lc.publish('dxyz_compare', msg.encode())

			msg = kalman_args_t()
			msg.input_rpy = self._last_rpy
			msg.input_acc = self._last_acc
			msg.input_dt = dt
			msg.valid_vicon = self._valid_vicon
			msg.meas_xyz = self._last_xyz
			msg.smooth_xyz = self._last_xyz
			msg.smooth_dxyz =self._last_dxyz
			self._xhat_lc.publish('kalman_args', msg.encode())

		else:
			xhat = [self._last_xyz[0],self._last_xyz[1],self._last_xyz[2],
					self._last_rpy[0],self._last_rpy[1],self._last_rpy[2],
					self._last_dxyz[0],self._last_dxyz[1],self._last_dxyz[2],
					self._last_gyro[0],self._last_gyro[1],self._last_gyro[2]]

		if self._delay_comp:
			control_inputs = self.get_last_inputs(self._delay)
			for ci in control_inputs:
				xhat = self._cf_model.simulate(xhat,ci[0],ci[1])

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

		# uncomment the following if you want to trigger hover at a predefined state
		# if 1.1-xhat[0] <= 0.01:
		# 	msg = crazyflie_hover_commands_t()
		# 	msg.hover = True
		# 	self._xhat_lc.publish('crazyflie_hover_commands',msg.encode())

		return xhat

	def get_time(self):
		if self._tvlqr_counting:
			self._current_dt += (time.time()-self._last_time_update)
		self._last_time_update = time.time()

		# uncomment the following if you want to trigger hover at a predefined time
		# if self._current_dt >= 6.125-.25:
		# 	msg = crazyflie_hover_commands_t()
		# 	msg.hover = True
		# 	self._xhat_lc.publish('crazyflie_hover_commands',msg.encode())

		return self._current_dt

	def _estimator_watchdog(self):
		_watchdog_lc = lcm.LCM()
		_watchdog_lc.subscribe('crazyflie_state_estimator_commands',self._estimator_watchdog_update)
		while True:
			_watchdog_lc.handle()

	def _estimator_watchdog_update(self, channel, data):
		msg = crazyflie_state_estimator_commands_t.decode(data)
		self._tvlqr_counting = msg.tvlqr_counting