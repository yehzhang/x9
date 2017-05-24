#! /usr/bin/env python3
from interpreter import Interpreter, Callback
from pdb import set_trace

class Debugger(Callback):
    def __init__(self):
        self.has_met = False

    def on_instruction_begin(self, inst, env):
        text = str(inst)
        print(text)
        if text in ('blt for_entry:', 'sw r0, RETURN_ADDR'):
            print(env)
            pass
        return

    def on_instruction_end(self, inst, env):
        return


def main():
    mem_default = [0] * 256
    mem_default[0] = 0
    mem_default[1] = 20
    mem_default[2] = 3
    config = {
       'reg_default': 0,
       'mem_default': mem_default,
    }
    cbs = [
        Debugger(),
    ]
    Interpreter(config, cbs).load('../targets/div_x9.s').run()
    print(mem_default[3])
    print(mem_default[4])

if __name__ == '__main__':
    main()
