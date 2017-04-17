from .instructions import Instruction


class Add(Instruction):
    mnemonic = 'add'

    def execute(self):
        self.env.acc += self.env.registers[self.rs]


class ShiftRight(Instruction):
    mnemonic = 'shr'

    def execute(self):
        raise NotImplementedError
