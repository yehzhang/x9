from .mapper import asm as S, machine_code as B
from .statement import Statement


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
        self.registers[self.rd] = self.alu_op(self.registers.r0, self.registers.r1)

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


class Add(RType):
    mnemonic = 'add'
    opcode = None  # TODO
    funct = None  # TODO

    def alu_op(self, a, b):
        # TODO take care of overflow?
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
