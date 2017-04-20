class Envrionment:

    def __init__(self, config):
        self.registers = Registers(config)
        self.memory = Memory(config)
        self.labels = {}
        self.should_exit = False

    def __str__(self):
        return str(self.registers)

    def exit(self):
        """ Called by instruction to exit """
        self.should_exit = True


class Registers:

    def __init__(self, config):
        assert len(config['reg_names']) <= 16
        assert 0 <= config['reg_default_value'] <= 0xff

        super().__setattr__('names', config['reg_names'])
        super().__setattr__('registers', {k: config['reg_default_value']
                                          for k in config['reg_names']})
        super().__setattr__('max_val', config['reg_max_value'])

    def __str__(self):
        regs_str = '\n'.join('\t{}: 0x{:02x}'.format(n, self.registers[n])
                             for n in self.names)
        return 'registers: \n{}'.format(regs_str)

    def __getattr__(self, name):
        return self.registers[name]

    def __setattr__(self, name, value):
        # TODO are registers signed?
        assert 0 <= value <= self.max_val

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
    """ Memory is of big-endian format.
    """

    def __init__(self, config):
        assert 0 <= config['mem_default_value'] <= 0xff
        assert 0 < config['mem_size']

        self.memory = [config['mem_default_value']] * config['mem_size']

    def __getitem__(self, key):
        """
        Load a byte at address 0xff: memory[0xff]
        Load a word at address 0xff: memory[0xff, 4]
        """
        if not isinstance(key, tuple):
            key = key,
        return self.load(*key)

    def __setitem__(self, key, value):
        """
        Store a byte at address 0xff: memory[0xff] = 0xab
        Store a word at address 0xff: memory[0xff, 4] = 0xab
        """
        if isinstance(key, tuple):
            addr, size = key
            key = addr, value, size
        else:
            key = key, value
        self.store(*key)

    def load(self, addr, size=1):
        assert 1 <= size
        assert 0 <= addr
        assert addr + size <= len(self.memory)

        num = 0
        for byte in self.memory[addr:addr+size]:
            num = (num << 8) | byte
        return num

    def store(self, addr, value, size=1):
        """ MSBs are discarded if `value' cannot be contained in `size' bytes """
        assert 1 <= size
        assert 0 <= addr
        assert addr + size <= len(self.memory)

        for i in range(size - 1, -1, -1):
            self.memory[addr + i] = value & 0xff
            value >>= 8
