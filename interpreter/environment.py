class Envrionment:

    def __init__(self, regs_mapping, mem_size):
        self.registers = Registers(regs_mapping, self)
        self.memory = [0] * mem_size
        self.labels = {}

    def __str__(self):
        return str(self.registers)


class Registers:
    MAX_VALUE = 0xff

    def __init__(self, regs_mapping, env):
        super().__setattr__('mapping', regs_mapping)
        super().__setattr__('registers', [0] * len(regs_mapping))
        super().__setattr__('env', env)

    def __str__(self):
        rev_mapping = {v: k for k, v in self.mapping.items()}
        regs_str = '\n'.join('\t{}: 0x{:02x}'.format(rev_mapping[i], reg)
                             for i, reg in enumerate(self.registers))
        return 'registers: \n{}'.format(regs_str)

    def __getattr__(self, reg_name):
        i_reg = self.get_index(reg_name)
        return self.registers[i_reg]

    def __setattr__(self, reg_name, value):
        value &= self.MAX_VALUE
        i_reg = self.get_index(reg_name)
        self.registers[i_reg] = value

    def __getitem__(self, key):
        if isinstance(key, str):
            key = self.get_index(key)
        return self.registers[key]

    def get_index(self, reg_name):
        i = self.mapping.get(reg_name)
        if i is None:
            raise RuntimeError('Register {} does not exist'.format(repr(reg_name)))
        return i
