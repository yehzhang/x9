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
        """ Subclasses overwrites this method to initialize attributes for readability when using
        mappers to set attributes.
        """
        raise NotImplementedError

    @classmethod
    def new_instance(cls, src, instruction_id, env, text):
        obj = cls(instruction_id, env)
        mapper = cls.get_mapper(src)
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
    machine_code_mapper = B.Bits('opcode', 3) | B.Bits('rd', 4) | B.Bits('funct', 2)

    def init_attrs(self):
        self.rd = None

    def execute(self):
        self.env.cout = 0  # cout is 0 unless add intruction
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
    machine_code_mapper = B.Bits('opcode', 3) | B.Bits('rs', 4) | B.Bits('rt', 1) | B.Unused(1)

    def init_attrs(self):
        self.rt = None
        self.rs = None


class IType(Instruction):
    asm_mapper = S.Mnemonic('mnemonic') | S.Register(
        'rt', 1) | S.MemoryAddressOrIntegerLiteral('imm', 5)
    machine_code_mapper = B.Bits('opcode', 3) | B.Bits('rt', 1) | B.Bits('imm', 5)

    def init_attrs(self):
        self.rt = None
        self.imm = None


class BType(Instruction):
    asm_mapper = S.Mnemonic('mnemonic') | S.LabelReference('imm', 4)

    funct = None
    machine_code_mapper = B.Bits('opcode', 3) | B.Bits('imm', 4) | B.Bits('funct', 2)

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


"""
    Implementation of Instructions
    Allow Assembly to Python Object Translation

    RType: a => r0, b => r1

"""


class Add(RType):
    mnemonic = 'add'
    opcode = 0
    funct = 0

    def alu_op(self, a, b):
        res = a + b
        if res > 255:
            self.env.cout = 1
            return res - 256
        return res


class AddCarryIn(RType):
    mnemonic = 'adc'
    opcode = 0
    funct = 1

    def alu_op(self, a, b):
        res = self.env.cout + a + b
        if res > 255:
            self.env.cout = 1
            return res - 256
        return res


class Subtract(RType):
    mnemonic = 'sub'
    opcode = 0
    funct = 2

    def alu_op(self, a, b):
        return a - b


# r0 store an address, this address point to some value
class LoadWordFromRegister(RType):
    mnemonic = 'lwr'
    opcode = 0
    funct = 3

    def alu_op(self, a, b):
        return self.env.memory[a]


# Notice: you can only load to r0 or r1
class LoadWord(IType):
    mnemonic = 'lw'
    opcode = 1

    def execute(self):
        lut = self.env.luts[self.mnemonic]
        address = lut[self.imm]
        self.registers[self.rt] = self.env.memory[address]


# Notice: you can only use r0 or r1 for rt
class StoreWord(IType):
    mnemonic = 'sw'
    opcode = 2

    def execute(self):
        lut = self.env.luts[self.mnemonic]
        address = lut[self.imm]
        self.env.memory[address] = self.registers[self.rt]


class BranchEqual(BType):
    mnemonic = 'beq'
    opcode = 3
    funct = 0

    def take_branch(self, a, b):
        return a == b


class BranchNotEqual(BType):
    mnemonic = 'bne'
    opcode = 3
    funct = 1

    def take_branch(self, a, b):
        return a != b


class BranchGreaterThan(BType):
    mnemonic = 'bgt'
    opcode = 3
    funct = 2

    def take_branch(self, a, b):
        return a > b


class BranchLessThan(BType):
    mnemonic = 'blt'
    opcode = 3
    funct = 3

    def take_branch(self, a, b):
        return a < b


class Move(MType):
    mnemonic = 'mov'
    opcode = 4

    def execute(self):
        self.registers[self.rt] = self.registers[self.rs]


# unsigned
class ShiftLeftLogical(RType):
    mnemonic = 'sll'
    opcode = 5
    funct = 0

    def alu_op(self, a, b):
        res = a << b
        if res > 255:
            return res & 255
        return res


# signed
class ShiftRightArithmetic(RType):
    mnemonic = 'sra'
    opcode = 5
    funct = 1

    def alu_op(self, a, b):
        return a >> b


class Negation(RType):
    mnemonic = 'neg'
    opcode = 6
    funct = 0

    def alu_op(self, a, b):
        return ~a


class And(RType):
    mnemonic = 'and'
    opcode = 6
    funct = 1

    def alu_op(self, a, b):
        return a & b


class Or(RType):
    mnemonic = 'or'
    opcode = 6
    funct = 2

    def alu_op(self, a, b):
        return a | b


class Halt(RType):
    mnemonic = 'halt'
    opcode = 6
    funct = 3

    def execute(self):
        self.env.pc = float('inf')

    def alu_op(self, a, b):
        pass


class Set(IType):
    mnemonic = 'set'
    opcode = 7

    def execute(self):
        self.registers[self.rt] = self.imm

