from interpreter import Interpreter

def main():
    Interpreter().load('examples/adds.s').run()

if __name__ == '__main__':
    main()
