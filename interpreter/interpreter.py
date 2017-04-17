from .parser import InstructionParser
from itertools import chain


class Interpreter:
    DEFAULT_CONFIG = {
        'regs_mapping': {
            'r0': 0,
            'r1': 1,
            'r2': 2,
            'r3': 3,
            'r4': 4,
            'r5': 5,
            'r6': 6,
            'r7': 7,
            'r8': 8,
            'r9': 9,
            'r10': 10,
            'r11': 11,
            'r12': 12,
            'at': 13,
            'pc': 14,
            'acc': 15,
        },
        'mem_size': 256,
    }

    def __init__(self, config=None):
        new_config = dict(self.DEFAULT_CONFIG)
        new_config.update(config or {})
        self.config = new_config

        self.env = None
        self.insts = None

    def load(self, filename, config=None):
        config = config or self.config

        # Create environment
        regs_mapping = config['regs_mapping']
        assert len(regs_mapping) <= 16
        self.env = Envrionment(regs_mapping, config['mem_size'])

        # Load instructions
        with open(filename) as fin:
            text = fin.read()
        self.insts, labels = InstructionParser.parse(text)

        # Mount instructions
        for inst in chain(self.insts, labels):
            inst.will_mount(self.insts, labels)

        return self

    def run(self):
        # Execute instructions
        for inst in self.insts:
            inst.execute()
            self.env.pc += 1

        print(self.env)
