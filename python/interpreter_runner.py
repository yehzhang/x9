#! /usr/bin/env python3
from interpreter import Interpreter


def main():
    # TODO fill in parameters
    mem_default = [0] * 256
    mem_default[1] = 0b00000001
    mem_default[2] = 0b00101100
    mem_default[3] = 0b00000001
    mem_default[4] = 0b10010000
    config = {
       'reg_default': 0,
       'mem_default': mem_default,
    }
    cbs = []
    Interpreter(config, cbs).load('../targets/all.s').run()


if __name__ == '__main__':
    main()
