from .environment import Environment
from .parser import Nano


class Interpreter:
    DEFAULT_CONFIG = {
        'reg_names':   [
            'r0',
            'r1',
            'r2',
            'r3',
            'r4',
            'r5',
            'r6',
            'r7',
            'r8',
            'r9',
            'r10',
            'r11',
            'r12',
            'r13',
            'r14',
            'r15',
        ],
        'reg_default': 0,
        'mem_size':    256,
        'mem_default': 0,
    }

    def __init__(self, config=None):
        new_config = dict(self.DEFAULT_CONFIG)
        new_config.update(config or {})
        self.config = new_config

        self.env = None
        self.insts = None

    def load(self, filename):
        self.env = Environment(self.config)
        self.insts = Nano(filename, self.env).parse()
        return self

    def run(self):
        """ Execute loaded instructions """
        if self.insts is None:
            raise RuntimeError('Assembly file is not loaded')

        self.env.pc = 0

        while True:
            if self.env.pc >= len(self.insts):
                break

            inst = self.insts[self.env.pc]
            inst.run()

            self.env.pc += 1

        print(self.env)
