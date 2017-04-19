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
    def get(mcs, ref_name):
        return mcs.insts[ref_name]


class Statement(metaclass=RegisterStatementFabric):
    mnemonic = None

    def __init__(self, instruction_id, env):
        self.instruction_id = instruction_id
        self.env = env


class Label(Statement):
    mnemonic = '__label'

    def __init__(self, instruction_id, env, name):
        super().__init__(instruction_id, env)
        self.name = name


class Instruction(Statement):
    mnemonic = None

    def __init__(self, instruction_id, env, operand1, operand2=None):
        super().__init__(instruction_id, env)
        self.operand1 = operand1
        self.operand2 = operand2

    def execute(self):
        raise NotImplementedError

    def as_byte_code(self):
        """ May be required in PA4? """
        raise NotImplementedError
