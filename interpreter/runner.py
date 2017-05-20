#! /usr/bin/env python3
from interpreter import Interpreter

def main():

    CUSTOM_CONFIG = {
       'reg_default': [2,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
       'mem_default': 7
    }
    Interpreter(CUSTOM_CONFIG).load('../targets/adds.s').run()

if __name__ == '__main__':
    main()