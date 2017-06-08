#! /usr/bin/env python3
from interpreter import Interpreter, Callback
from pdb import set_trace
from interpreter.environment import convert_to_signed_integer

class Debugger(Callback):
    def on_instruction_begin(self, inst, env):
        pass

    def on_instruction_end(self, inst, env):
        text = str(inst)
        print(text)
        if text in ('add r15'):
            print(env)
            set_trace()
            pass
        return

        return


def main():
    mem_default = [0] * 256
    mem_default[1] = 0x10
    mem_default[2] = 0x00
    mem_default[3] = 0x10
    mem_default[4] = 0x00
    config = {
       'reg_default': 0,
       'mem_default': mem_default,
    }
    cbs = [
        Debugger(),
    ]
    Interpreter(config, cbs).load('../targets/cordic_x9.s').run()

    print(mem_default[5])
    print(mem_default[6])
    print(mem_default[7])
    print(mem_default[8])

if __name__ == '__main__':
    main()
