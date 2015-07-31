import lcm
import math
import numpy as np
from crazyflie_t import crazyflie_input_t, crazyflie_controller_commands_t, crazyflie_hover_commands_t, crazyflie_positioninput_t
from threading import Thread

GO_TO_START = True
XHAT_START = [0, -0.61, 0.01, 0, 0, 0, 0, 0, 0, 0, 0, 0]
NOMINAL_W2 = 16.3683
XHAT_DESIRED = [0, -0.61, 0.50, 0, 0, 0, 0, 0, 0, 0, 0, 0]

ROLL_KP = 3.5*180/math.pi
PITCH_KP = 3.5*180/math.pi
YAW_KP = 0
ROLL_RATE_KP = 70*180/math.pi
PITCH_RATE_KP = 70*180/math.pi
YAW_RATE_KP = 50*180/math.pi
K32bits = np.array([[0,0,0,0,PITCH_KP,YAW_KP,0,0,0,0,PITCH_RATE_KP,YAW_RATE_KP],
                    [0,0,0,ROLL_KP,0,-YAW_KP,0,0,0,ROLL_RATE_KP,0,-YAW_RATE_KP],
                    [0,0,0,0,-PITCH_KP,YAW_KP,0,0,0,0,-PITCH_RATE_KP,YAW_RATE_KP],
                    [0,0,0,-ROLL_KP,0,-YAW_KP,0,0,0,-ROLL_RATE_KP,0,-YAW_RATE_KP]])

ROLL_KP = .7
PITCH_KP = .7
YAW_KP = 0
ROLL_RATE_KP = .8
PITCH_RATE_KP = .8
YAW_RATE_KP = .6
Komegasqu = np.array([[0,0,0,0,PITCH_KP,YAW_KP,0,0,0,0,PITCH_RATE_KP,YAW_RATE_KP],
                       [0,0,0,ROLL_KP,0,-YAW_KP,0,0,0,ROLL_RATE_KP,0,-YAW_RATE_KP],
                       [0,0,0,0,-PITCH_KP,YAW_KP,0,0,0,0,-PITCH_RATE_KP,YAW_RATE_KP],
                       [0,0,0,-ROLL_KP,0,-YAW_KP,0,0,0,-ROLL_RATE_KP,0,-YAW_RATE_KP]])

Ktilqr = np.array([[ 7.1623,   -0.0000,  -15.8114,    0.0000,    6.3078,   11.1803,    2.0167,   -0.0000,   -7.2476,    0.0000,    1.0742,    3.3139],
    			  [ 0.0000,   -7.1623,  -15.8114,    6.3078,   0.0000,  -11.1803,    0.0000,   -2.0167,   -7.2476,    1.0742,   -0.0000,   -3.3139],
                  [-7.1623,   -0.0000,  -15.8114,    0.0000,   -6.3078,   11.1803,   -2.0167,   -0.0000,   -7.2476,    0.0000,   -1.0742,    3.3139],
                  [-0.0000,   7.1623,  -15.8114,   -6.3078,   -0.0000,  -11.1803,    0.0000,    2.0167,   -7.2476,   -1.0742,    0.0000,   -3.3139]])

# This is Ben's hand-tuned K matrix.  TILQR from drake with position cost increased.
Kpostilqr = np.array([
   [-0.0000,    3.6690,   -0.0000,   -0.5318,   -0.0000,    0.0000,   -0.0000,    0.2581,   -0.0000,   -0.0079,   -0.0000,    0.0000],
   [-3.6690,    0.0000,    0.0000,   -0.0000,   -0.5318,   -0.0000,   -0.2581,    0.0000,   -0.0000,   -0.0000,   -0.0079,    0.0000],
    [0.0000,    0.0000,    0.0000,   -0.0000,    0.0000,   -1.2046,    0.0000,    0.0000,    0.0000,   -0.0000,    0.0000,   -0.1210],
   [-0.0000,   12.2322,   -0.0000,  -10.6368,   -0.0000,    0.0000,   -0.0000,    5.1625,   -0.0000,   -0.1579,   -0.0000,    0.0000],
  [-12.2322,    0.0000,    0.0000,   -0.0000,  -10.6368,   -0.0000,   -5.1625,    0.0000,   -0.0000,   -0.0000,   -0.1579,    0.0000],
    [0.0000,    0.0000,    0.0000,   -0.0000,    0.0000,  -17.2087,    0.0000,    0.0000,    0.0000,   -0.0000,    0.0000,   -1.7292],
   [-0.0000,    0.0000,  -37.4166,   -0.0000,   -0.0000,    0.0000,   -0.0000,    0.0000,   -6.3931,   -0.0000,   -0.0000,    0.0000],
 ])


# Input mode in the Crazyflie
MODES = {
'32bits':       1,
'omegasqu':     2,
'onboardpd':    3,
}

class Controller():
	
	def __init__(self, control_input_type='32bits', listen_to_lcm=False, control_input_updated_flag=None,
				 listen_to_extra_input=False, publish_to_lcm=False, pos_control=False):

		self._pos_control = pos_control

		self._go_to_start = GO_TO_START

		self._is_running = True
		Thread(target=self._controller_watchdog).start()
		
		self._hover = False
		self._reset_xhat_desired = False
		self._xhat_desired = np.array(XHAT_DESIRED).transpose()
		Thread(target=self._hover_watchdog).start()

		self._K = {'32bits': K32bits, 'omegasqu': Komegasqu, 'tilqr': Ktilqr, 'postilqr': Kpostilqr}

		if self._pos_control:
			self._latest_control_input = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
		else:
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

		if self._pos_control:
			if not self._is_running:
				return [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
			
			if self._listen_to_lcm or not xhat:
				control_input = list(self._latest_control_input)
			else:
				control_input = np.dot(self._K.get('postilqr'),np.array(xhat).transpose()-(self._xhat_desired+np.array([self._extra_control_input[0], self._extra_control_input[1], 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]))).tolist()
				control_input[6] += NOMINAL_W2 - 15.0
			
			if self._reset_xhat_desired:
				if self._go_to_start:
					self._xhat_desired = np.array(XHAT_START).transpose()
					self._go_to_start = False
				else:
					self._xhat_desired = np.array([xhat[0], xhat[1], xhat[2], 0, 0, 0, 0, 0, 0, 0, 0, 0]).transpose()
				self._reset_xhat_desired = False

			if self._hover:
				control_input = np.dot(self._K.get('postilqr'),np.array(xhat).transpose()-self._xhat_desired).tolist()
				control_input[6] += NOMINAL_W2 - 15.0
			
			if self._listen_to_extra_input:
				control_input[6] += self._extra_control_input[4]
			
			if self._publish_to_lcm:
				msg = crazyflie_positioninput_t()
				msg.input = control_input
				self._control_input_lc.publish('crazyflie_input', msg.encode())
			
			return control_input

		if not self._is_running:
			return [0.0, 0.0, 0.0, 0.0, 0.0, MODES.get(self._control_input_type,1)]

		if self._listen_to_lcm or not xhat:
			control_input = list(self._latest_control_input)
		else:
			thrust_input = np.dot(self._K.get(self._control_input_type),np.array(xhat).transpose()-self._xhat_desired).tolist()
			control_input = thrust_input + [0.0, MODES.get(self._control_input_type,1)]

		if self._reset_xhat_desired:
			if self._go_to_start:
				self._xhat_desired = np.array(XHAT_START).transpose()
				self._go_to_start = False
			else:
				self._xhat_desired = np.array([xhat[0], xhat[1], xhat[2], 0, 0, 0, 0, 0, 0, 0, 0, 0]).transpose()
			self._reset_xhat_desired = False
			
		if self._hover:
			xhat_error = np.array(xhat).transpose()-self._xhat_desired
			thrust_input = np.dot(self._K.get('tilqr'),xhat_error).tolist()
			thrust_input[0] += NOMINAL_W2 - 15
			thrust_input[1] += NOMINAL_W2 - 15
			thrust_input[2] += NOMINAL_W2 - 15
			thrust_input[3] += NOMINAL_W2 - 15
			control_input = thrust_input + [0.0, MODES.get('omegasqu',2)]

		if self._listen_to_extra_input:
			assert control_input[5] == self._extra_control_input[5], 'The extra input is not of the right type'
			control_input[0] += self._extra_control_input[0]
			control_input[1] += self._extra_control_input[1]
			control_input[2] += self._extra_control_input[2]
			control_input[3] += self._extra_control_input[3]
			control_input[4] += self._extra_control_input[4]

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
		if self._pos_control:
			msg = crazyflie_positioninput_t.decode(data)
			self._latest_control_input = list(msg.input)
		else:
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