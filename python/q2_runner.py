#! /usr/bin/env python3
from interpreter import Interpreter, Callback
from pdb import set_trace

class Debugger(Callback):
    def __init__(self):
        self.has_met = False

    def on_instruction_begin(self, inst, env):
        text = str(inst)
        print(text)
        if text in ('blt for_entry:'):
            # print(env)
            pass
        return

    def on_instruction_end(self, inst, env):
        return


def main():
    # Test Case 1
    # s = '01001' * 102 + '00'
    # pattern = 0b1001

    # Test Case 3
    s = '1' * 64 * 8
    pattern = 0b1111

    mem_default = [0] * 256
    string = [int(s[i*8:(i + 1)*8], 2) for i in range(len(s) // 8)]
    print(', '.join('{:08b}'.format(s) for s in string))
    mem_default[32:32+len(string)] = string
    mem_default[9] = pattern
    mem_default[255] = 255  # max_int
    config = {
       'reg_default': 0,
       'mem_default': mem_default,
    }
    cbs = [
        Debugger(),
    ]
    env = Interpreter(config, cbs).load('../targets/string_match_x9.s').run()
    print(env)
    print('Result count', env.memory[10])

if __name__ == '__main__':
    main()
