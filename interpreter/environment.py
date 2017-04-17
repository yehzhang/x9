class Envrionment:

    def __init__(self, regs_mapping, mem_size):
        self.registers = Registers(regs_mapping)
        self.memory = [0] * mem_size
        self.labels = {}

    def __str__(self):
        regs_str = ', '.join(self._registers)
        return 'registers: {}'.format(regs_str)


class Registers:

    def __init__(self, regs_mapping):
        super().__setattr__('mapping', regs_mapping)
        super().__setattr__('registers', [0xff] * len(regs_mapping))

    def __getattr__(self, reg_name):
        i_reg = self.mapping[reg_name]
        return self.registers[i_reg]

    def __setattr__(self, reg_name, value):
        i_reg = self.mapping[reg_name]
        self.registers[i_reg] = value
