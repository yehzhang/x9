class Envrionment:

    def __init__(self, config):
        self.registers = Registers(config)
        self.memory = Memory(config)
        self.labels = {}
        self.should_exit = False
        self.next_pc = None

    def __str__(self):
        return str(self.registers)

    def exit(self):
        """ Called by instruction to exit """
        self.should_exit = True

    def jump_to(self, label_name):
        """ Set the value of pc of the next clock cycle """
        if self.next_pc is not None:
            raise RuntimeError("Register 'pc' is already set in this clock cycle")
        label = self.labels[label_name]
        self.next_pc = label.instruction_id

    def fetch_maybe_updated_pc(self):
        """
        :return: new pc if set or current pc
        """
        if self.next_pc is not None:
            next_pc = self.next_pc
            self.next_pc = None
        else:
            next_pc = self.registers.pc
        return next_pc


class Registers:

    def __init__(self, config):
        assert len(config['reg_names']) <= 16
        assert 0 <= config['reg_default_value'] <= 0xff

        super().__setattr__('names', config['reg_names'])
        super().__setattr__('registers', {k: config['reg_default_value']
                                          for k in config['reg_names']})

        # # TODO need to take care of register overflow?
        # self.max_val = config['reg_max_value']

    def __str__(self):
        regs_str = '\n'.join('\t{}: 0x{:02x}'.format(n, self.registers[n])
                             for n in self.names)
        return 'registers: \n{}'.format(regs_str)

    def __getattr__(self, name):
        return self.registers[name]

    def __setattr__(self, name, value):
        self.registers[name] = value

    def __getitem__(self, key):
        if isinstance(key, int):
            key = self.names[key]
        return self.registers[key]


def make_byte_list(size, default=None):
    """
    :param default: either an int or a list
    """
    raise NotImplementedError


class Memory:

    def __init__(self, config):
        assert 0 <= config['mem_default_value'] <= 0xff

        self.memory = [config['mem_default_value']] * config['mem_size']

    def __getitem__(self, key):
        if isinstance(key, tuple):
            return self.load(*key)
        return self.memory[key]

    def load(self, addr, size=1):
        assert isinstance(addr, int)

        num = 0
        for byte in self.memory[addr:addr+size]:
            num = (num << 8) | byte
        return num
