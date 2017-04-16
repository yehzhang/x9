class RegisterInstructionFabric(type):
    """Register classes of instructions."""
    insts = {}

    def __new__(mcs, name, bases, nmspc):
        cls = super().__new__(mcs, name, bases, nmspc)

        ref_name = nmspc.get('name')
        if ref_name is not None:
            mcs.insts[ref_name] = cls

        return cls

    def get(cls, ref_name):
        return cls.insts[ref_name]


class Instruction(metaclass=RegisterInstructionFabric):
    name = None

    def __init__(self, num_ln, env):
        self.num_ln = line_number
        self.env = env

    def will_mount(self, env, insts, labels):
        """ Called before running.
            Note that not all instructions are mounted at this time.
        """
        pass

    def read_register(self, i):
        return self.env.registers[i]


class Label(Instruction):
    name = '__label'

    def will_mount(self, insts, labels):
        self.env.labels[self.num_ln] = self


class Executable(Instruction):
    mnemonic = None

    def __init__(self, num_ln, env, rs, rt=None):
        super().__init__(num_ln, env)
        self.rs = rs
        self.rt = rt

    @property
    def name(self):
        return self.mnemonic

    def execute(self):
        raise NotImplementedError

    def as_byte_code(self):
        raise NotImplementedError


class Add(Executable):
    mnemonic = 'add'

    def execute(self):
        self.env.accumulator += self.read_register(self.rs)


class ShiftRight(Executable):
    mnemonic = 'shr'

    def execute(self):
        raise NotImplementedError
