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
    string = [0b01001010, 0b10010100, 0b00010001, 0b01010000]
    mem_default[32:32+len(string)] = string
    mem_default[9] = 0b0101  # pattern
    mem_default[255] = 255  # max_int
    config = {
       'reg_default': 0,
       'mem_default': mem_default,
    }
    cbs = [
        Debugger(),
    ]
    Interpreter(config, cbs).load('../targets/string_match_x9.s').run()

if __name__ == '__main__':
    main()
