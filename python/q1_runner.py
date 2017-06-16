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
        # if text in ('add r15'):
        #     print(env)
        #     set_trace()
        #     pass

        return


def main(test_case):
    if test_case == 0:
        x = 0x100
        y = 0x100
        radian = 595
        theta = 2105

    if test_case == 1:
        x = 0x100
        y = 0x50
        radian = 440
        theta = 961

    if test_case == 2:
        x = 0x50
        y = 0x100
        radian = 440
        theta = 3105

    if test_case == 3:
        x = 0x100
        y = 0x0
        radian = 421
        theta = 345


    mem_default = [0] * 256
    mem_default[1] = x >> 4
    mem_default[2] = (x & 0xf) << 4
    mem_default[3] = y >> 4
    mem_default[4] = (y & 0xf) << 4
    config = {
       'reg_default': 0,
       'mem_default': mem_default,
    }
    cbs = [
        # Debugger(),
    ]
    env = Interpreter(config, cbs).load('../targets/cordic_x9.s').run()

    print('R & Theta are', env.memory.load(5, 2) >> 4, env.memory.load(7, 2) >> 4, 'should be', radian, theta)
    # print()

if __name__ == '__main__':
    for i in range(4):
        main(i)
