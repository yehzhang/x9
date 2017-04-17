class RegisterStatementFabric(type):
    """Register classes of statements."""
    insts = {}

    def __new__(mcs, name, bases, nmspc):
        cls = super().__new__(mcs, name, bases, nmspc)

        ref_name = getattr(cls, 'mnemonic')
        if ref_name is not None:
            mcs.insts[ref_name] = cls

        return cls

    @classmethod
    def get(cls, ref_name):
        return cls.insts[ref_name]


class Statement(metaclass=RegisterStatementFabric):
    mnemonic = None

    def __init__(self, instruction_id, env):
        self.instruction_id = instruction_id
        self.env = env

    def execute(self):
        raise NotImplementedError


class Label(Statement):
    mnemonic = '__label'

    def __init__(self, instruction_id, env, name):
        super().__init__(instruction_id, env)
        self.name = name
        env.labels[name] = self

    def execute(self):
        pass


class Instruction(Statement):
    mnemonic = None

    def __init__(self, instruction_id, env, rs, rt=None):
        super().__init__(instruction_id, env)
        self.rs = rs
        self.rt = rt

    def as_byte_code(self):
        """ May be required in PA4? """
        raise NotImplementedError
