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
    type_name = 'statement'

    def __init__(self, instruction_id, env, operands):
        self.instruction_id = int(instruction_id)
        self.env = env
        self._init_attrs(operands)

    def _init_attrs(self):
        raise NotImplementedError

    def as_assembly_code(self):
        raise NotImplementedError

    def __repr__(self):
        return '<{} {}>'.format(self.mnemonic, self.type_name)

    __str__ = as_assembly_code


class Label(Statement):
    mnemonic = 'label'

    def _init_attrs(self, operands):
        self.name, = operands


class Instruction(Statement):
    type_name = 'instruction'

    def _execute(self):
        raise NotImplementedError

    def as_byte_code(self):
        """ May be required in PA4? """
        raise NotImplementedError

    def execute(self):
        self.env.execution_count += 1
        self._execute()


class RType(Instruction):

    def _init_attrs(self, operands):
        if len(operands) != 2:
            raise ValueError('Invalid number of operands')
        if any(op not in self.env.registers.names for op in operands):
            raise ValueError("Register not found in the environment")
        self.operand1, self.operand2 = operands

    @property
    def reg1(self):
        return self.registers[self.operand1]

    @property
    def reg2(self):
        return self.registers[self.operand2]

    @property
    def regs(self):
        return self.env.registers


class IType(Instruction):

    def _init_attrs(self, operands):
        self.immediate = int(immediate, 0)
