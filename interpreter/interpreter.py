from .parser import Nano
from .environment import Envrionment


class Interpreter:
    DEFAULT_CONFIG = {
        'reg_mapping': {
            'r0': 0,
            'r1': 1,
            'r2': 2,
            'r3': 3,
            'r4': 4,
            'r5': 5,
            'r6': 6,
            'r7': 7,
            'r8': 8,
            't0': 9,
            't1': 10,
            't2': 11,
            't3': 12,
            'at': 13,  # assembler temporary
            'pc': 14,
            'ac': 15,  # accumulator
        },
        'reg_max_value': 0xff,
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

    def load(self, filename, config=None):
        config = config or self.config

        # Create environment
        assert len(config['reg_mapping']) <= 16
        self.env = Envrionment(config)

        # Load instructions
        self.insts = Nano.parse(filename, self.env)

        return self

    def run(self):
        # Execute instructions
        while not self.env.should_exit:
            inst = self.insts[self.env.registers.pc]
            inst.execute()
            self.env.tick()

        print(self.env)
