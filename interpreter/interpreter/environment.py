from collections import defaultdict

class Environment:
    def __init__(self, config):
        self.registers = Registers(config)
        self.memory = Memory(config)
        # :type Dict[str, Label]: {label_name: Label}
        self.labels = {}
        self.execution_count = 0
        self.aliases = {}
        # :type Dict[str, Dict[str, int]]: populated by TokenMappers in asm module
        # e.g. instruction_id = luts[BranchEqual.mnemonic][immediate]
        # e.g. addr = luts[LoadWord.mnemonic][immediate]
        self.luts = defaultdict(dict)
        self.pc = 0
        self.cout = 0

    def __str__(self):
        return '\n'.join([
            'Registers: \n{}'.format(self.registers.as_str(1)),
            'Dynamic instruction count: {}'.format(self.execution_count)
        ])

    def unalias(self, op):
        return self.aliases.get(op, op)


class Registers:
    def __init__(self, config):
        assert len(config['reg_names']) <= 16

        super().__setattr__('names', config['reg_names'])

        regs = make_bytes(config['reg_default'], len(self.names))
        regs = dict(zip(self.names, regs))
        super().__setattr__('registers', regs)

    def __str__(self):
        return self.as_str(0)

    def as_str(self, indent):
        return '\n'.join('{}{}: {}'.format(
            '\t' * indent, n, str(self.registers[n])) for n in self.names)

    def __getattr__(self, name):
        return self.registers[name].get()

    def __setattr__(self, name, value):
        self.registers[name].set(value)

    def __getitem__(self, key):
        """
        :param int key:
        """
        return self.__getattr__(self.names[key])

    def __setitem__(self, key, value):
        """
        :param int key:
        """
        return self.__setattr__(self.names[key], value)


class Memory:
    """ Memory is of big-endian format.
    """

    def __init__(self, config):
        assert 0 <= config['mem_default'] <= 0xff
        assert 0 < config['mem_size']

        self.memory = make_bytes(config['mem_default'], config['mem_size'])

    def __str__(self):
        return '\n'.join(' '.join(map(str, self.memory[i:i + 8]))
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
                upper_bound = 2 ** (size * 8)
                value -= upper_bound

        return value

    def store(self, addr, value, size=1):
        assert 1 <= size
        assert 0 <= addr
        assert addr + size <= len(self.memory)

        value = convert_to_unsigned_integer(value, size * 8)
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
        self.value = convert_to_unsigned_integer(value, 8)
        return self

    def get(self):
        return self.value


def convert_to_unsigned_integer(value, size):
    """
    :param int size: number of bits containing this integer
    """
    upper_bound = 2 ** size
    if not (-upper_bound // 2 <= value < upper_bound):
        msg = '{} is out of range of {} bytes'.format(value, size)
        raise ValueError(msg)
    all_f_mask = upper_bound - 1
    return value & all_f_mask


def make_bytes(default, size=None):
    """
    :param int|List[int] default:
    :param int size: number of bytes in the list, if default is int
    :return List[Byte]:
    """
    if isinstance(default, int):
        if size is None:
            raise ValueError("'size' is not specified when default is int")
        return [Byte().set(default) for _ in range(size)]

    bytes = [Byte().set(d) for d in default]
    if size is not None and len(bytes) != size:
        raise ValueError("'default' and 'size' are not of the same length")
    return bytes
