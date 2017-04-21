from .statement import Instruction


class Add(Instruction):
    mnemonic = 'add'

    def execute(self):
        # TODO take care of overflow?
        self.env.registers.ac += self.env.registers[self.operand1]


class ShiftRight(Instruction):
    mnemonic = 'shr'

    def execute(self):
        raise NotImplementedError


class Jump(Instruction):

    def jump(self, label_name):
        label = self.env.labels[label_name]
        self.env.registers.pc = label.instruction_id


class Nop(Instruction):
    mnemonic = '__nop'

    def execute(self):
        pass
