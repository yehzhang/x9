from .mapper import asm, machine_code as mc
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
    asm_mapper = asm.Mnemonic() | asm.Register('rd', 4)

    funct = None
    machine_code_mapper = mc.Opcode('opcode', 3) | mc.Register('rd', 4) | mc.Funct('funct', 2)

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
    asm_mapper = asm.Mnemonic() | asm.Register('rt', 1) | asm.Register('rs', 4)
    machine_code_mapper = mc.Opcode('opcode', 3) | mc.Register(
        'rs', 4) | mc.Register('rt', 1) | mc.Unused(1)

    def init_attrs(self):
        self.rt = None
        self.rs = None


class IType(Instruction):
    asm_mapper = asm.Mnemonic() | asm.Register('rt', 1) | asm.Immediate('imm', 5)
    machine_code_mapper = mc.Opcode('opcode', 3) | mc.Register('rt', 1) | mc.Immediate('imm', 5)

    def init_attrs(self):
        self.rt = None
        self.imm = None


class BType(Instruction):
    asm_mapper = asm.Mnemonic() | asm.Immediate('imm', 4)

    funct = None
    machine_code_mapper = mc.Opcode('opcode', 3) | mc.Immediate('imm', 4) | mc.Funct('funct', 2)

    def init_attrs(self):
        self.imm = None

    def execute(self):
        if self.take_branch(self.registers.r0, self.registers.r1):
            label = self.env.labels[self.imm]
            # interpreter increments pc in each cycle
            self.registers.pc = label.instruction_id - 1

    def take_branch(self):
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
