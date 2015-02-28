#!/usr/bin/env python2

import time
import pygame
import pygame.midi
import lcm
from crazyflie_t import crazyflie_input_t

# INPUT_TYPE = '32bits'
# INPUT_MIN = 0
# INPUT_MAX = 65000

INPUT_TYPE = 'omegasqu'
INPUT_MIN = 0
INPUT_MAX = 25

# INPUT_TYPE = 'onboardpd'
# INPUT_MIN = 0
# INPUT_MAX = 65000

# INPUT_TYPE = 'offsetonly'
# INPUT_MIN = 0
# INPUT_MAX = 25

INPUT_FREQ = 200.0;
class LCMChannels:
    INPUT = 'crazyflie_input'
    OFFSET = 'crazyflie_extra_offset'


class Kon():

    def __init__(self):
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

            if name == "nanoKONTROL MIDI 1" and input:
                in_id = i
            elif name == "nanoKONTROL MIDI 1" and output:
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

    def forward_kon_to_lcm(self):
        self.read_input()        
        msg = crazyflie_input_t()
        msg.input[0] = (self.sliders.get(2,0)/127.0)*(INPUT_MAX-INPUT_MIN)+INPUT_MIN
        msg.input[1] = (self.sliders.get(3,0)/127.0)*(INPUT_MAX-INPUT_MIN)+INPUT_MIN
        msg.input[2] = (self.sliders.get(4,0)/127.0)*(INPUT_MAX-INPUT_MIN)+INPUT_MIN
        msg.input[3] = (self.sliders.get(5,0)/127.0)*(INPUT_MAX-INPUT_MIN)+INPUT_MIN
        msg.offset = (self.sliders.get(6,0)/127.0)*(INPUT_MAX-INPUT_MIN)+INPUT_MIN
        msg.type = INPUT_TYPE
        if INPUT_TYPE=='offsetonly':
            self.lc.publish(LCMChannels.OFFSET, msg.encode())
        else:
            self.lc.publish(LCMChannels.INPUT, msg.encode())


if __name__=='__main__':
    kon = Kon()
    while True:
        kon.forward_kon_to_lcm()
        time.sleep(1.0/INPUT_FREQ)