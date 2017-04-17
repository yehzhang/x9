from .statement import Instruction


class Add(Instruction):
    mnemonic = 'add'

    def execute(self):
        self.env.registers.acc += self.env.registers[self.rs]


class ShiftRight(Instruction):
    mnemonic = 'shr'

    def execute(self):
        raise NotImplementedError
