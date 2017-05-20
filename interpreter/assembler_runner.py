from interpreter import Assembler
import os.path

def main():
    Assembler().load('../targets/adds.s').run(os.path.abspath('../../../Desktop/'))

if __name__ == '__main__':
    main()