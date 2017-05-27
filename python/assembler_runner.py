from interpreter import Assembler
import os.path

def main():
    Assembler().load('../targets/all.s').run('~/Downloads/output')

if __name__ == '__main__':
    main()
