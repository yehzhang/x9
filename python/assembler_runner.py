from interpreter import Assembler
import os.path

def main():
    Assembler().load('../targets/string_match_x9.s').run('~/Downloads/output')

if __name__ == '__main__':
    main()
