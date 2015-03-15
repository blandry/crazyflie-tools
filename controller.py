import lcm
import math
import numpy as np
from crazyflie_t import crazyflie_input_t, crazyflie_controller_commands_t
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

# Input mode in the Crazyflie
MODES = {
'32bits':       1,
'omegasqu':     2,
'onboardpd':    3,
}

class Controller():
	
	def __init__(self, control_input_type='32bits', listen_to_lcm=False, control_input_updated_flag=None,
				 listen_to_extra_input=False, publish_to_lcm=False):

		self._is_running = True
		Thread(target=self._controller_watchdog).start()

		self._K = {'32bits': K32bits, 'omegasqu': Komegasqu}
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