from .statement import Instruction


class Add(Instruction):
    mnemonic = 'add'

    def execute(self):
        self.env.registers.ac += self.env.registers[self.operand1]


class ShiftRight(Instruction):
    mnemonic = 'shr'

    def execute(self):
        raise NotImplementedError
