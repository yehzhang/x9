class RegisterStatementFabric(type):
    """Register classes of statements."""
    insts = {}

    def __new__(mcs, name, bases, nmspc):
        cls = super().__new__(mcs, name, bases, nmspc)

        ref_name = nmspc.get('name')
        if ref_name is not None:
            mcs.insts[ref_name] = cls

        return cls

    def get(cls, ref_name):
        return cls.insts[ref_name]


class Statement(metaclass=RegisterStatementFabric):
    name = None

    def __init__(self, instruction_id, env):
        self.instruction_id = instruction_id
        self.env = env


class Label(Statement):
    name = '__label'

    def will_mount(self, insts, labels):
        """ Called before running. """
        self.env.labels[self.instruction_id] = self


class Instruction(Statement):
    mnemonic = None

    def __init__(self, instruction_id, env, rs, rt=None):
        super().__init__(instruction_id, env)
        self.rs = rs
        self.rt = rt

    @property
    def name(self):
        return self.mnemonic

    def execute(self):
        raise NotImplementedError

    def as_byte_code(self):
        """ May be required in PA4? """
        raise NotImplementedError
