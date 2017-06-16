#! /usr/bin/env python3
from interpreter import Interpreter, Callback
from pdb import set_trace

class Debugger(Callback):
    def __init__(self):
        self.has_met = False

    def on_instruction_begin(self, inst, env):
        # text = str(inst)
        # print(text)
        # if text in ('set r0, FIFTEEN', 'sw r0, RETURN_ADDR'):
        #     print(env)
        #     set_trace()
        #     pass
        return

    def on_instruction_end(self, inst, env):
        text = str(inst)
        print(text)
        #'set r0, FIFTEEN', 'sw r0, RETURN_ADDR'
        if text in ('set r1, 28'):
            print(env)
            set_trace()
            pass
        return

        return


def main():

    f = 0

    if f == 0:
        mem_default = [0] * 256
        mem_default[128] = 0x10 # 1000 => 4096
        mem_default[129] = 0x00
        mem_default[130] = 0x10 # 10 => 16
        #256
        result = 256

    if f == 1:
        mem_default = [0] * 256
        mem_default[128] = 0x7F # 32767
        mem_default[129] = 0xFF
        mem_default[130] = 0x7F # 127
        result = 258
    
    if f == 2:
        mem_default = [0] * 256
        mem_default[128] = 0x00 # 111
        mem_default[129] = 0x6F
        mem_default[130] = 0x70 # 112
        result = 0

    if f == 3:
        mem_default = [0] * 256
        mem_default[128] = 0x01 # 256
        mem_default[129] = 0x00
        mem_default[130] = 0x10 # 16
        result = 16

    if f == 4:
        mem_default = [0] * 256
        mem_default[128] = 0x5A # 23130
        mem_default[129] = 0x5A
        mem_default[130] = 0x78 # 120
        result = 192



    config = {
       'reg_default': 0,
       'mem_default': mem_default,
    }
    cbs = [
        Debugger(),
    ]
    Interpreter(config, cbs).load('../targets/div_x9.s').run()



if __name__ == '__main__':
    main()
