from .mapper import TokenMapper


class MachineCode(TokenMapper):
    def __init__(self, attr, underscore=True):
        super().__init__(attr)
        self.sep = '_' if underscore else ''

    def join(self, token, text):
        return token + self.sep + text


class Bits(MachineCode):
    def __init__(self, attr, bits):
        super().__init__(attr)
        self.fmt = '{{:0{}b}}'.format(bits)

    def compose(self, env, value):
        """
        :return str: a string of 0s and 1s
        """
        return self.fmt.format(value)


class Unused(Bits):
    def __init__(self, bits):
        super().__init__(None, bits)

    def compose(self, env, value):
        return super().compose(env, 0)
