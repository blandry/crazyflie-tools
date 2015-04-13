import lcm
import math
import numpy as np
from crazyflie_t import crazyflie_input_t, crazyflie_controller_commands_t, crazyflie_hover_commands_t
from threading import Thread


ROLL_KP = 3.5*180/math.pi
PITCH_KP = 3.5*180/math.pi
YAW_KP = 0
ROLL_RATE_KP = 70*180/math.pi
PITCH_RATE_KP = 70*180/math.pi
YAW_RATE_KP = 50*180/math.pi
K32bits = np.matrix([[0,0,0,0,PITCH_KP,YAW_KP,0,0,0,0,PITCH_RATE_KP,YAW_RATE_KP],
                    [0,0,0,ROLL_KP,0,-YAW_KP,0,0,0,ROLL_RATE_KP,0,-YAW_RATE_KP],
                    [0,0,0,0,-PITCH_KP,YAW_KP,0,0,0,0,-PITCH_RATE_KP,YAW_RATE_KP],
                    [0,0,0,-ROLL_KP,0,-YAW_KP,0,0,0,-ROLL_RATE_KP,0,-YAW_RATE_KP]])

ROLL_KP = .7
PITCH_KP = .7
YAW_KP = 0
ROLL_RATE_KP = .8
PITCH_RATE_KP = .8
YAW_RATE_KP = .6
Komegasqu = np.matrix([[0,0,0,0,PITCH_KP,YAW_KP,0,0,0,0,PITCH_RATE_KP,YAW_RATE_KP],
                       [0,0,0,ROLL_KP,0,-YAW_KP,0,0,0,ROLL_RATE_KP,0,-YAW_RATE_KP],
                       [0,0,0,0,-PITCH_KP,YAW_KP,0,0,0,0,-PITCH_RATE_KP,YAW_RATE_KP],
                       [0,0,0,-ROLL_KP,0,-YAW_KP,0,0,0,-ROLL_RATE_KP,0,-YAW_RATE_KP]])

# Ktilqr = np.matrix([[5.0000,-0.0000,-4.3301,0.0137,7.4915,2.5000,2.7635,-0.0025,-3.7928,0.0038,1.0343,2.2539],
#     				[0.0000,-5.0000,-4.3301,7.4915,0.0137,-2.5000,0.0025,-2.7635,-3.7928,1.0343,0.0038,-2.2539],
#    					[-5.0000,0.0000,-4.3301,-0.0137,-7.4915,2.5000,-2.7635,0.0025,-3.7928,-0.0038,-1.0343,2.2539],
#    					[-0.0000,5.0000,-4.3301,-7.4915,-0.0137,-2.5000,-0.0025,2.7635,-3.7928,-1.0343,-0.0038,-2.2539]])

Ktilqr = np.matrix([[ 3.1623,   -0.0000,  -15.8114,    0.0000,    6.3078,    2.2361,    2.0167,   -0.0000,   -7.2476,   -0.0000,    1.0742,    1.7878],
					[-0.0000,   -3.1623,  -15.8114,    6.3078,   -0.0000,   -2.2361,   -0.0000,   -2.0167,   -7.2476,    1.0742,   -0.0000,   -1.7878],
					[-3.1623,   -0.0000,  -15.8114,    0.0000,   -6.3078,    2.2361,   -2.0167,   -0.0000,   -7.2476,    0.0000,   -1.0742,    1.7878],
					[ 0.0000,    3.1623,  -15.8114,   -6.3078,    0.0000,   -2.2361,    0.0000,    2.0167,   -7.2476,   -1.0742,    0.0000,   -1.7878]])

# Input mode in the Crazyflie
MODES = {
'32bits':       1,
'omegasqu':     2,
'onboardpd':    3,
}

class Controller():
	
	def __init__(self, control_input_type='32bits', listen_to_lcm=False, control_input_updated_flag=None,
				 listen_to_extra_input=False, publish_to_lcm=False):

		self._go_to_start = True

		self._is_running = True
		Thread(target=self._controller_watchdog).start()

		self._hover = False
		self._reset_xhat_desired = False
		self._xhat_desired = np.zeros([12,1])
		Thread(target=self._hover_watchdog).start()

		self._K = {'32bits': K32bits, 'omegasqu': Komegasqu, 'tilqr': Ktilqr}
		self._latest_control_input = [0.0, 0.0, 0.0, 0.0, 0.0, MODES.get(control_input_type,1)]
		self._control_input_type = control_input_type

		self._control_input_updated_flag = control_input_updated_flag

		self._listen_to_lcm = listen_to_lcm
		if listen_to_lcm:
			publish_to_lcm = False
			Thread(target=self._control_input_listener).start()

		self._publish_to_lcm = publish_to_lcm
		if publish_to_lcm:
			self._control_input_lc = lcm.LCM()

		self._listen_to_extra_input = listen_to_extra_input
		if listen_to_extra_input:
			self._extra_control_input = [0.0, 0.0, 0.0, 0.0, 0.0, MODES.get(self._control_input_type,1)]
			Thread(target=self._extra_input_thread).start()

	def get_control_input(self, xhat=None):

		if not self._is_running:
			return [0.0, 0.0, 0.0, 0.0, 0.0, MODES.get(self._control_input_type,1)]

		if self._listen_to_lcm or not xhat:
			control_input = list(self._latest_control_input) # note how we create a NEW list
		else:
			thrust_input = (np.array(np.dot(self._K.get(self._control_input_type),np.array(xhat).transpose()))[0]).tolist()
			control_input = thrust_input + [0.0, MODES.get(self._control_input_type,1)]

		if self._reset_xhat_desired:
			if self._go_to_start:
				self._xhat_desired = np.array([-1.8, 0, 1.25, 0, 0, 0, 0, 0, 0, 0, 0, 0]).transpose()
				self._go_to_start = False
			else:
				self._xhat_desired = np.array([xhat[0], xhat[1], xhat[2], 0, 0, 0, 0, 0, 0, 0, 0, 0]).transpose()
			self._reset_xhat_desired = False
		if self._hover:
			xhat_error = np.array(xhat).transpose()-self._xhat_desired
			thrust_input = (np.array(np.dot(self._K.get('tilqr'),xhat_error))[0]).tolist()
			thrust_input[0] += 16.2950 - 15
			thrust_input[1] += 16.2950 - 15
			thrust_input[2] += 16.2950 - 15
			thrust_input[3] += 16.2950 - 15
			control_input = thrust_input + [0.0, MODES.get('omegasqu',2)]

		if self._listen_to_extra_input:
			assert control_input[5] == self._extra_control_input[5], 'The extra input is not of the right type'
			control_input[0] += self._extra_control_input[0]
			control_input[1] += self._extra_control_input[1]
			control_input[2] += self._extra_control_input[2]
			control_input[3] += self._extra_control_input[3]
			control_input[4] += self._extra_control_input[4]
			# this is why we had to create a new list

		if self._publish_to_lcm:
			msg = crazyflie_input_t()
			msg.input = control_input[0:4]
			msg.offset = control_input[4]
			msg.type = self._control_input_type
			self._control_input_lc.publish('crazyflie_input', msg.encode())

		return control_input

	def _control_input_listener(self):
		_control_input_listener_lc = lcm.LCM()
		_control_input_listener_lc.subscribe('crazyflie_input',self._update_control_input)
		while True:
			_control_input_listener_lc.handle()

	def _update_control_input(self, channel, data):
		msg = crazyflie_input_t.decode(data)
		self._latest_control_input = list(msg.input) + [msg.offset, MODES.get(msg.type,1)]
		self._control_input_type = msg.type
		if self._control_input_updated_flag:
			self._control_input_updated_flag.set()

	def _extra_input_thread(self):
		_extra_input_lc = lcm.LCM()
		_extra_input_lc.subscribe('crazyflie_extra_input',self._update_extra_input)
		while True:
			_extra_input_lc.handle()

	def _update_extra_input(self, channel, data):
		msg = crazyflie_input_t.decode(data)
		self._extra_control_input = list(msg.input) + [msg.offset, MODES.get(msg.type,1)]

	def _controller_watchdog(self):
		_watchdog_lc = lcm.LCM()
		_watchdog_lc.subscribe('crazyflie_controller_commands',self._controller_watchdog_update)
		while True:
			_watchdog_lc.handle()

	def _controller_watchdog_update(self, channel, data):
		msg = crazyflie_controller_commands_t.decode(data)
		self._is_running = msg.is_running

	def _hover_watchdog(self):
		_hover_lc = lcm.LCM()
		_hover_lc.subscribe('crazyflie_hover_commands',self._hover_watchdog_update)
		while True:
			_hover_lc.handle()

	def _hover_watchdog_update(self, channel, data):
		msg = crazyflie_hover_commands_t.decode(data)
		if not(self._hover) and msg.hover:
			self._reset_xhat_desired = True
		self._hover = msg.hover 