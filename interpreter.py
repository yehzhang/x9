from .parser import InstructionParser
from itertools import chain


class Interpreter:
    DEFAULT_CONFIG = {
        'num_regs': 8,
        'mem_size': 256,
    }

    def __init__(self, config):
        new_config = dict(self.DEFAULT_CONFIG)
        new_config.update(config)
        self.config = new_config

        self.env = None
        self.insts = None

    def load(self, filename, config=None):
        config = config or self.config

        # Create environment
        self.env = Envrionment(config['num_regs'], config['mem_size'])

        # Load instructions
        with open(filename) as fin:
            text = fin.read()
        self.insts, labels = InstructionParser.parse(text)

        # Mount instructions
        for inst in chain(self.insts, labels):
            inst.will_mount(self.insts, labels)

    def run(self):
        # Execute instructions
        for inst in self.insts:
            inst.execute()
            # TODO Does $pc += 4 after being modified by this instruction?
            self.env.program_counter += 1

        print('registers: {}'.format(', '.format(self.registers)))


class Envrionment:

    def __init__(self, num_regs, mem_size):
        self.memory = [0xff] * mem_size

        self.registers = [0xff] * num_regs
        self.i_accumulator = 0

        self.program_counter = 0

        self.labels = {}

    @property
    def accumulator(self):
        return self.registers[self.i_accumulator]
