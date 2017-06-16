#! /usr/bin/env python3
from interpreter import Interpreter, Callback
from pdb import set_trace

class Debugger(Callback):
    def __init__(self):
        self.has_met = False

    def on_instruction_begin(self, inst, env):
        text = str(inst)
        print(text)
        if text in ('mov r0, i'):
            print(env)
            print(text)
            set_trace()
            pass
        return

    def on_instruction_end(self, inst, env):
        # text = str(inst)
        # print(text)
        # #'set r0, FIFTEEN', 'sw r0, RETURN_ADDR'
        # if text in ('set r1, 28'):
        #     print(env)
        #     set_trace()
        #     pass
        pass


def main(test_case):
    if test_case == 0:
        dividend_MSB = 0x10 # 1000 => 4096
        dividend_LSB = 0x00
        divisor = 0x10 # 10 => 16
        #256
        solution = 256

    if test_case == 1:
        dividend_MSB = 0x7F # 32767
        dividend_LSB = 0xFF
        divisor = 0x7F # 127
        solution = 258

    if test_case == 2:
        dividend_MSB = 0x00 # 111
        dividend_LSB = 0x6F
        divisor = 0x70 # 112
        solution = 0

    if test_case == 3:
        dividend_MSB = 0x01 # 256
        dividend_LSB = 0x00
        divisor = 0x10 # 16
        solution = 16

    if test_case == 4:
        dividend_MSB = 0x5A # 23130
        dividend_LSB = 0x5A
        divisor = 0x78 # 120
        solution = 192


    mem_default = [0] * 256
    mem_default[128] = dividend_MSB
    mem_default[129] = dividend_LSB
    mem_default[130] = divisor

    config = {
       'reg_default': 0,
       'mem_default': mem_default,
    }
    cbs = [
        Debugger(),
    ]
    env = Interpreter(config, cbs).load('../targets/div_x9.s').run()

    result = env.memory.load(126, 2, True)
    print('Result is', result, 'should be', solution)



if __name__ == '__main__':
    for i in range(5):
        main(i)
