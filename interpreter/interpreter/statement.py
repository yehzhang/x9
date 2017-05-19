from .mapper import asm as S, machine_code as B



class RegisterStatementFabric(type):
    """Register classes of statements."""
    insts = {}

    def __new__(mcs, name, bases, nmspc):
        cls = super().__new__(mcs, name, bases, nmspc)

        ref_name = getattr(cls, 'mnemonic')
        if ref_name is not None:
            if ref_name not in mcs.insts:
                mcs.insts[ref_name] = cls

                # TODO Sanity check of duplicate (opcode, funct)?

        return cls

    @classmethod
    def get(mcs, ref_name):
        cls = mcs.insts.get(ref_name)
        if cls is None:
            raise ValueError('Unknown statement name')
        return cls


class Statement(metaclass=RegisterStatementFabric):
    mnemonic = None

    # Add mappers here to support more languages
    asm_mapper = None
    machine_code_mapper = None

    def __init__(self, instruction_id, env):
        self.instruction_id = instruction_id
        self.env = env
        self.init_attrs()

    def init_attrs(self):
        """ Subclasses overwrites this method to initialize attributes. """
        raise NotImplementedError

    @classmethod
    def new_instance(cls, src, instruction_id, env, text):
        obj = cls(instruction_id, env)
        mapper = self.get_mapper(src)
        mapper.deserialize(env, text, obj)
        return obj

    def as_code(self, target):
        mapper = self.get_mapper(target)
        return mapper.serialize(self.env, self)

    def __repr__(self):
        return '<{} {}>'.format(type(self).__name__, self.mnemonic)

    @classmethod
    def get_mapper(cls, lang):
        mapper = getattr(cls, lang + '_mapper', None)
        if mapper is None:
            raise NotImplementedError('Mapper is not supported')
        return mapper


class Label(Statement):
    mnemonic = 'label'

    asm_mapper = S.Mnemonic('mnemonic') | S.Id('name')

    def init_attrs(self):
        self.name = None


class Instruction(Statement):
    opcode = None

    def execute(self):
        raise NotImplementedError

    def run(self):
        self.env.execution_count += 1
        self.execute()

    def __str__(self):
        return self.as_code('asm')

    @property
    def registers(self):
        return self.env.registers


class RType(Instruction):
    asm_mapper = S.Mnemonic('mnemonic') | S.Register('rd', 4)

    funct = None
    machine_code_mapper = B.Opcode('opcode', 3) | B.Bits('rd', 4) | B.Bits('funct', 2)

    def init_attrs(self):
        self.rd = None

    def execute(self):
        alu_out = self.alu_op(self.registers.r0, self.registers.r1)
        # TODO take care of overflow
        self.registers[self.rd] = alu_out

    def alu_op(self, a, b):
        """
        :param int a:
        :param int b:
        :return int:
        """
        raise NotImplementedError


class MType(Instruction):
    asm_mapper = S.Mnemonic('mnemonic') | S.Register('rt', 1) | S.Register('rs', 4)
    machine_code_mapper = B.Opcode('opcode', 3) | B.Bits('rs', 4) | B.Bits('rt', 1) | B.Unused(1)

    def init_attrs(self):
        self.rt = None
        self.rs = None


class IType(Instruction):
    asm_mapper = S.Mnemonic('mnemonic') | S.Register(
        'rt', 1) | S.MemoryAddressOrIntegerLiteral('imm', 5)
    machine_code_mapper = B.Opcode('opcode', 3) | B.Bits('rt', 1) | B.Bits('imm', 5)

    def init_attrs(self):
        self.rt = None
        self.imm = None


class BType(Instruction):
    asm_mapper = S.Mnemonic('mnemonic') | S.LabelReference('imm', 4)

    funct = None
    machine_code_mapper = B.Opcode('opcode', 3) | B.Bits('imm', 4) | B.Bits('funct', 2)

    def init_attrs(self):
        # :type int:
        self.imm = None

    def execute(self):
        if self.take_branch(self.registers.r0, self.registers.r1):
            lut = self.env.luts[self.mnemonic]
            instruction_id = lut[self.imm]
            # interpreter increments pc in each cycle
            self.env.pc = instruction_id - 1

    def take_branch(self, a, b):
        """
        :param int a:
        :param int b:
        :return bool:
        """
        raise NotImplementedError


class Add(RType):
    mnemonic = 'add'
    opcode = None  # TODO
    funct = None  # TODO

    def alu_op(self, a, b):
        return a + b


class ShiftRightArithmetic(RType):
    mnemonic = 'sra'
    opcode = None  # TODO
    funct = None  # TODO

    def alu_op(self, a, b):
        # TODO
        raise NotImplementedError


class BranchEqual(BType):
    mnemonic = 'beq'
    opcode = None  # TODO
    funct = None  # TODO

    def take_branch(self, a, b):
        return a == b
