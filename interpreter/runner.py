#! /usr/bin/env python3
from interpreter import Interpreter

def main():
    Interpreter().load('../targets/adds.s').run()

if __name__ == '__main__':
    main()
