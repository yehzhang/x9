from collections import defaultdict


class Environment:
    def __init__(self, config):
        self.aliases = {}
        self.registers = Registers(self.aliases, config)
        self.memory = Memory(config)
        # :type Dict[str, Label]: {label_name: Label}
        self.labels = {}
        self.execution_count = 0
        # :type Dict[str, Dict[str, int]]: populated by TokenMappers in asm module
        # e.g. instruction_id = luts[BranchEqual.mnemonic][immediate]
        # e.g. addr = luts[LoadWord.mnemonic][immediate]
        self.luts = defaultdict(dict)
        self._acc_luts = defaultdict(dict)
        # :type int: not a genuine register
        self.pc = 0
        self.cout = 0

    def __repr__(self):
        items = [
            ('Memory', repr(self.memory)),
            ('Registers', self.registers.as_str(self.aliases)),
            ('Dynamic instruction count', str(self.execution_count)),
        ]
        str_items = []
        for k, v in items:
            lns = v.splitlines()
            if len(lns) > 1:
                v = ''.join('\n\t' + ln for ln in lns)
            s = '{}: {}'.format(k, v)
            str_items.append(s)
        return '\n'.join(str_items)

    def unalias(self, op):
        return self.aliases.get(op, op)


class Registers:
    def __init__(self, aliases, config):
        assert len(config['reg_names']) <= 16

        super().__setattr__('names', config['reg_names'])

        regs = make_bytes(config['reg_default'], len(self.names))
        regs = dict(zip(self.names, regs))
        super().__setattr__('registers', regs)

        super().__setattr__('aliases', aliases)

    def __repr__(self):
        return self.as_str()

    def as_str(self, aliases=None):
        inv_aliases = {v: k for k, v in self.aliases.items()}
        return '\n'.join('{}: {}'.format(
            inv_aliases.get(n, n), self.registers[n]) for n in self.names)

    def __getattr__(self, name):
        name = self.aliases.get(name, name)
        return self.registers[name].get()

    def __setattr__(self, name, value):
        name = self.aliases.get(name, name)
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
        assert 0 < config['mem_size']

        self.memory = make_bytes(config['mem_default'], config['mem_size'])

    def __repr__(self):
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

        if signed:
            value = convert_to_signed_integer(value, size * 8)

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

    def __repr__(self):
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
        msg = '{} is out of range of {} bits'.format(value, size)
        raise ValueError(msg)
    all_f_mask = upper_bound - 1
    return value & all_f_mask


def convert_to_signed_integer(value, size):
    """
    :param int size: number of bits containing this integer
    """
    upper_bound = 2 ** size
    if not (-upper_bound // 2 <= value < upper_bound):
        msg = '{} is out of range of {} bits'.format(value, size)
        raise ValueError(msg)
    if value >= 0:
        msb_mask = 1 << (size - 1)
        if value & msb_mask:
            value -= upper_bound
    return value


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
