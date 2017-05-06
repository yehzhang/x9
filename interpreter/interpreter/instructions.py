from .statement import RType, IType


class Add(RType):
    mnemonic = 'add'

    def _execute(self):
        # TODO take care of overflow?
        self.regs.ac = self.reg1 + self.reg2


class ShiftRight(RType):
    mnemonic = 'shr'

    def _execute(self):
        raise NotImplementedError


class BranchEQ(RType):
    mnemonic = 'beq'

    def _execute(self):
        if self.reg1 == self.reg2:
            label = self.env.labels[label_name]
            self.regs.pc = label.instruction_id


class Nop(Instruction):
    mnemonic = 'nop'

    def _init_attrs(self, operands):
        if operands:
            raise ValueError('Invalid number of operands')

    def _execute(self):
        self.env.execution_count -= 1
