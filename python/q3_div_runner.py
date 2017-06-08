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
    mem_default = [0] * 256
    mem_default[128] = 0x00
    mem_default[129] = 0x6f
    mem_default[130] = 0x70
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
