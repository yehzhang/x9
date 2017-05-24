from .environment import convert_to_signed_integer
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
        alu_out = self.alu_op(self.registers.r0, self.registers.r1)
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
        :param int a: Signed
        :param int b: Signed
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
        self.env.cout = 0
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
        self.env.cout = 0
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


class BranchLessThanSigned(BType):
    mnemonic = 'blts'
    opcode = 3
    funct = 2

    def take_branch(self, a, b):
        return convert_to_signed_integer(a, 8) < convert_to_signed_integer(b, 8)


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
        if b<0:
            res = a>>b
        else:
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
        a = convert_to_signed_integer(a)
        if b<0:
            res = a << b
        else:
            res = a >> b
        if res > 255:
            return res & 255
        return res


class ShiftRightLogical(RType):
    mnemonic = 'srl'
    opcode = 5
    funct = 2

    def alu_op(self, a, b):
        if b<0:
            res = a << b
        else:
            res = a >> b
        if res > 255:
            return res & 255
        return res


class Negation(RType):
    mnemonic = 'neg'
    opcode = 6
    funct = 0

    def alu_op(self, a, b):
        temp = 0xFF
        return a ^ temp


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


class Pseudo(Instruction):
    asm_template = None

    def __init__(self, instruction_id, env):
        super().__init__(instruction_id, env)
        self.insts = []

    def execute(self):
        for inst in self.insts:
            inst.execute()
        self.env.execution_count -= 1

    @classmethod
    def new_instance(cls, src, instruction_id, env, text):
        obj = super().new_instance(src, instruction_id, env, text)
        assert isinstance(obj, cls)

        # Replace tokens
        mappers = cls.get_mapper(src).mappers
        repls = {m.attr: getattr(obj, m.src_attr) for m in mappers if m.attr is not None}
        template = getattr(cls, src + '_template')
        text = template.format(**repls)

        # New instructions
        for s in text.strip().splitlines():
            mne, _ = s.strip().split(maxsplit=1)
            s_cls = RegisterStatementFabric.get(mne)
            inst = s_cls.new_instance(src, None, env, s)
            obj.insts.append(inst)

        return obj

    def as_code(self, target):
        return '\n'.join(inst.as_code(target) for inst in self.insts)



class ShiftCarry(Pseudo):
    asm_mapper = S.Mnemonic('mnemonic') | S.Register('reg_m', 4) | S.Register(
        'reg_l', 4) | S.Register('shamt', 4) | S.Register('reg_mr', 4) | S.Register(
        'reg_lr', 4)

    def init_attrs(self):
        self.reg_m = None
        self.reg_l = None
        self.shamt = None
        self.reg_mr = None
        self.reg_lr = None


class ShiftRightLogicalCarry(ShiftCarry):
    """ Using registers: r0, r1, r2

    RTL
        reg_l = reg_l >>> shamt
        reg_l = reg_l | (reg_m << (8 - shamt))
        reg_m = reg_m >>> shamt

    x9
        # reg_l >>> shamt
        mov r0, reg_l
        set r1, shamt
        srl r2
        # 8 - shamt
        set r0, 8
        sub r1
        # reg_m << (8 - shamt)
        mov r0, reg_m
        sll r1
        # reg_l = reg_l | (reg_m << (8 - shamt))
        mov r0, r2
        or reg_l
        # reg_m = reg_m >>> shamt
        mov r0, reg_m
        set r1, shamt
        srl reg_m
    """
    mnemonic = 'srlc'
    asm_template = '''\
        mov r0 {reg_l}
        mov r1 {shamt}
        srl r2
        set r0 8
        sub r1
        mov r0 {reg_m}
        sll r1
        mov r0 r2
        or {reg_lr}
        mov r0 {reg_m}
        mov r1 {shamt}
        srl {reg_mr}'''


class ShiftLeftLogicalCarry(ShiftCarry):
    """ Using registers: r0, r1, r2

    RTL
        reg_m = reg_m << shamt
        reg_m = reg_m | (reg_l >>> (8 - shamt))
        reg_l = reg_l << shamt

    x9
        # reg_m << shamt
        mov r0, reg_m
        set r1, shamt
        sll r2
        # 8 - shamt
        set r0, 8
        sub r1
        # reg_l >>> (8 - shamt)
        mov r0, reg_l
        srl r1
        # reg_m = reg_m | (reg_l >>> (8 - shamt))
        mov r0, r2
        or reg_m
        # reg_l = reg_l << shamt
        mov r0, reg_l
        set r1, shamt
        sll reg_l
    """
    mnemonic = 'sllc'
    asm_template = '''\
        mov r0 {reg_m}
        mov r1 {shamt}
        sll r2
        set r0 8
        sub r1
        mov r0 {reg_l}
        srl r1
        mov r0 r2
        or {reg_mr}
        mov r0 {reg_l}
        mov r1 {shamt}
        sll {reg_lr}'''
