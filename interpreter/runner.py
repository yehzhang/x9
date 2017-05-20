#! /usr/bin/env python3
from interpreter import Interpreter, Callback

class debugger(Callback):
    def on_instruction_begin(self, inst, env):
        print('on_instruction_begin: {}'.format(inst))

    def on_instruction_end(self, inst, env):
        print('on_instruction_end: {}'.format(inst))


def main():
    db = debugger()

    CUSTOM_CONFIG = {
       'reg_default': [1,2,0,0,0,9,0,0,0,0,0,0,0,0,0,0],
       'mem_default': 7
    }
    Interpreter(CUSTOM_CONFIG, [db]).load('../targets/adds.s').run()

if __name__ == '__main__':
    main()