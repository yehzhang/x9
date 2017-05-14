from .mapper import BitConstrained


class MachineCode(BitConstrained):
    def __init__(self, attr, bits):
        super().__init__(attr, bits)
        self.fmt = '{{:0{}b}}'.format(bits)

    def compose(self, env, value):
        """
        :return str: a string of 0s and 1s
        """
        num = self.to_int(env, value)
        return self.fmt.format(num)

    def to_int(self, env, value):
        """
        :param str value:
        :return int:
        """
        raise NotImplementedError


class Id(MachineCode):
    def to_int(self, env, value):
        return value


class Opcode(Id):
    pass


class Register(MachineCode):
    def to_int(self, env, value):
        """
        :param str value: r0, r2, etc
        """
        return int(value[1:])


class Immediate(Id):
    pass


class Funct(Id):
    pass


class Unused(MachineCode):
    def __init__(self, bits):
        super().__init__(None, bits)

    def to_int(self, env, value):
        return 0
