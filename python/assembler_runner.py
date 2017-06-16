from interpreter import Assembler
import os.path

def main():
    Assembler().load('../targets/cordic_x9.s').run('~/Desktop/machine_code')

if __name__ == '__main__':
    main()
