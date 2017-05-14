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

    def execute(self):
        self.registers[self.rd] = self.binop(
            self.registers.r0, self.registers.r1)

    def binop(self, a, b):
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


class IType(Instruction):
    asm_mapper = asm.Mnemonic() | asm.Register('rt', 1) | asm.Immediate('imm', 5)
    machine_code_mapper = mc.Opcode('opcode', 3) | mc.Register('rt', 1) | mc.Immediate('imm', 5)


class BType(Instruction):
    asm_mapper = asm.Mnemonic() | asm.Immediate('imm', 4)

    funct = None
    machine_code_mapper = mc.Opcode('opcode', 3) | mc.Immediate('imm', 4) | mc.Funct('funct', 2)

    def execute(self):
        if self.branch_taken():
            label = self.env.labels[self.imm]
            # interpreter increments pc in each cycle
            self.registers.pc = label.instruction_id - 1

    def branch_taken(self):
        """
        :return bool:
        """
        raise NotImplementedError


class Add(RType):
    mnemonic = 'add'
    opcode = None
    funct = None

    def binop(self, a, b):
        # TODO take care of overflow?
        return a + b


class ShiftRightArithmetic(RType):
    mnemonic = 'sra'

    def binop(self, a, b):
        raise NotImplementedError


class BranchEqual(BType):
    mnemonic = 'beq'

    def branch_taken(self):
        return self.registers.r0 == self.registers.r1
