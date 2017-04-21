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
        registers = {k: Byte().set(config['reg_default_value'])
                     for k in config['reg_names']}
        super().__setattr__('registers', registers)

    def __str__(self):
        regs_str = '\n'.join('\t{}: {}'.format(n, str(self.registers[n]))
                             for n in self.names)
        return 'registers: \n{}'.format(regs_str)

    def __getattr__(self, name):
        return self.registers[name].get()

    def __setattr__(self, name, value):
        self.registers[name].set(value)

    def __getitem__(self, key):
        if isinstance(key, int):
            key = self.names[key]
        return self.__getattr__(key)


class Memory:
    """ Memory is of big-endian format.
    """

    def __init__(self, config):
        assert 0 <= config['mem_default_value'] <= 0xff
        assert 0 < config['mem_size']

        self.memory = [Byte().set(config['mem_default_value'])
                       for _ in range(config['mem_size'])]

    def __str__(self):
        return '\n'.join(' '.join(map(str, self.memory[i:i+8]))
                         for i in range(0, len(self.memory), 8))

    def __getitem__(self, key):
        """
        Load an unsigned byte at address 0xff: memory[0xff]
        Load an unsigned word at address 0xff: memory[0xff, 4]
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

    def load(self, addr, size=1, signed=False):
        assert 1 <= size
        assert 0 <= addr
        assert addr + size <= len(self.memory)

        value = 0
        for i in range(addr, addr + size):
            byte = self.memory[i].get()
            value = (value << 8) | byte

        # Convert to signed integer
        if signed:
            msb_mask = 1 << (size * 8 - 1)
            if value & msb_mask:  # if negative
                max_value = 2 ** (size * 8)
                value -= max_value

        return value

    def store(self, addr, value, size=1):
        assert 1 <= size
        assert 0 <= addr
        assert addr + size <= len(self.memory)

        value = convert_to_unsigned_integer(value, size)
        for i in range(size - 1, -1, -1):
            self.memory[addr + i].set(value & 0xff)
            value >>= 8


class Byte:

    def __init__(self):
        self.value = 0

    def __str__(self):
        return '0x{:02x}'.format(self.value)

    def set(self, value):
        # Signed minimum and unsigned maximum
        self.value = convert_to_unsigned_integer(value, 1)
        return self

    def get(self):
        return self.value


def convert_to_unsigned_integer(value, size):
    max_value = 2 ** (size * 8)
    if not (-max_value // 2 <= value < max_value):
        msg = '{} is out of range of {} bytes'.format(value, size)
        raise ValueError(msg)
    all_f_mask = max_value - 1
    return value & all_f_mask
