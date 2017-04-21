from .parser import Nano
from .environment import Envrionment


class Interpreter:
    DEFAULT_CONFIG = {
        'reg_names': [
            'pc',
            'ac',  # accumulator
            'r0',
            'r1',
            'r2',
            'r3',
            'r4',
            'r5',
            'r6',
            'r7',
            'r8',
            't0',
            't1',
            't2',
            't3',
        ],
        'reg_default_value': 0,
        'mem_size': 256,
        'mem_default_value': 0,
    }

    def __init__(self, config=None):
        new_config = dict(self.DEFAULT_CONFIG)
        new_config.update(config or {})
        self.config = new_config

        self.env = None
        self.insts = None

    def load(self, filename):
        self.env = Envrionment(self.config)
        labels, self.insts = Nano.parse(filename, self.env)
        # Add references to labels
        for label in labels:
            self.env.labels[label.name] = label
        return self

    def run(self):
        """ Execute loaded instructions """
        if self.insts is None:
            raise RuntimeError('Assembly file is not loaded')

        # Skip the first nop instruction
        self.env.registers.pc = 1

        while True:
            if self.env.should_exit:
                break
            if self.env.registers.pc >= len(self.insts):
                break

            inst = self.insts[self.env.registers.pc]
            inst.execute()

            self.env.registers.pc += 1

        print(self.env)
