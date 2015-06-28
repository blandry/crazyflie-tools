#!/usr/bin/env python2

import time
import pygame
import pygame.midi
import lcm
from crazyflie_t import crazyflie_input_t, crazyflie_state_estimator_commands_t, crazyflie_controller_commands_t, crazyflie_hover_commands_t

# INPUT_TYPE = '32bits'
# INPUT_MIN = 0
# INPUT_MAX = 65000

INPUT_TYPE = 'omegasqu'
INPUT_MIN = 0.0
INPUT_MAX = 15.0

# INPUT_TYPE = 'onboardpd'
# INPUT_MIN = 0
# INPUT_MAX = 65000

IS_EXTRA_INPUT = True
INPUT_FREQ = 200.0;

class Kon():

    def __init__(self):
        self._tvlqr_counting = False
        self._is_running = True
        self._hover = False
        self._last_hover_update = time.time()

        pygame.init()
        pygame.midi.init()
        (in_device_id, out_device_id) = self.find_nano_kontrol()
        self.midi_in = pygame.midi.Input(in_device_id)
        print "using input  id: %s" % in_device_id
        self.sliders = dict(zip(range(2,14), [0]*12))
        self.lc = lcm.LCM()

    def find_nano_kontrol(self):
        print "ID: Device Info"
        print "---------------"
        in_id = None
        out_id = None
        for i in range( pygame.midi.get_count() ):
            r = pygame.midi.get_device_info(i)
            (interf, name, input, output, opened) = r

            in_out = ""
            if input:
                in_out = "(input)"
            if output:
                in_out = "(output)"

            if name == "nanoKONTROL2 MIDI 1" and input:
                in_id = i
            elif name == "nanoKONTROL2 MIDI 1" and output:
                out_id = i

            print ("%2i: interface :%s:, name :%s:, opened :%s:  %s" %
                   (i, interf, name, opened, in_out))

        return (in_id, out_id)

    def read_input(self):
        if self.midi_in.poll():
            midi_events = self.midi_in.read(100)
            midi_evs = pygame.midi.midis2events(midi_events, self.midi_in.device_id)
            for me in midi_evs:
                self.sliders[me.data1] = me.data2
                #print "%s: %s" % (me.data1,me.data2)

    def forward_kon_to_lcm(self):
        self.read_input()        
        
        msg = crazyflie_input_t()
        msg.input[0] = (self.sliders.get(0,0)/127.0)*(INPUT_MAX-INPUT_MIN)*.1+INPUT_MIN
        msg.input[1] = (self.sliders.get(1,0)/127.0)*(INPUT_MAX-INPUT_MIN)*.1+INPUT_MIN
        msg.input[2] = (self.sliders.get(2,0)/127.0)*(INPUT_MAX-INPUT_MIN)+INPUT_MIN
        msg.input[3] = (self.sliders.get(3,0)/127.0)*(INPUT_MAX-INPUT_MIN)+INPUT_MIN
        msg.offset = (self.sliders.get(4,0)/127.0)*(INPUT_MAX-INPUT_MIN)+INPUT_MIN
        msg.type = INPUT_TYPE
        if IS_EXTRA_INPUT:
            self.lc.publish('crazyflie_extra_input', msg.encode())
        else:
            self.lc.publish('crazyflie_input', msg.encode())
        
        tvlqr_play = self.sliders.get(41)
        if not(self._tvlqr_counting) and tvlqr_play==127:
            self._hover = False
            msg = crazyflie_hover_commands_t()
            msg.hover = self._hover
            self.lc.publish('crazyflie_hover_commands', msg.encode())
            self._last_hover_update = time.time()
            msg = crazyflie_state_estimator_commands_t()
            msg.tvlqr_counting = True
            self.lc.publish('crazyflie_state_estimator_commands', msg.encode())
            self._tvlqr_counting = True

        tvlqr_stop = self.sliders.get(45)
        if self._tvlqr_counting and tvlqr_stop==127:
            self._hover = True
            msg = crazyflie_hover_commands_t()
            msg.hover = self._hover
            self.lc.publish('crazyflie_hover_commands', msg.encode())
            self._last_hover_update = time.time()
            msg = crazyflie_state_estimator_commands_t()
            msg.tvlqr_counting = False
            self.lc.publish('crazyflie_state_estimator_commands', msg.encode())
            self._tvlqr_counting = False

        reset_stop_all = self.sliders.get(43)
        if reset_stop_all==127:
            msg = crazyflie_controller_commands_t()
            msg.is_running = True
            self.lc.publish('crazyflie_controller_commands', msg.encode())
            self._is_running = True

        stop_all = self.sliders.get(45)
        if stop_all==127:
            msg = crazyflie_controller_commands_t()
            msg.is_running = False
            self.lc.publish('crazyflie_controller_commands', msg.encode())
            self._is_running = False

        hover = self.sliders.get(60)
        if hover==127 and (time.time()-self._last_hover_update)>.5:
            self._hover = not(self._hover)
            msg = crazyflie_hover_commands_t()
            msg.hover = self._hover
            self.lc.publish('crazyflie_hover_commands', msg.encode())
            self._last_hover_update = time.time()


def main():
    kon = Kon()
    while True:
        kon.forward_kon_to_lcm()
        time.sleep(1.0/INPUT_FREQ)   

if __name__=='__main__':
    main()