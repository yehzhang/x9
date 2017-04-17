from .instructions import Executable


class Add(Executable):
    mnemonic = 'add'

    def execute(self):
        self.env.acc += self.env.registers[self.rs]


class ShiftRight(Executable):
    mnemonic = 'shr'

    def execute(self):
        raise NotImplementedError
