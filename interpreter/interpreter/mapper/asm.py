from .mapper import TokenMapper, BitConstrained


class Asm(TokenMapper):
    def tokenize(self, text):
        segments = text.split(maxsplit=1)
        if len(segments) == 1:
            segments.append('')
        return segments


class Id(Asm):
    def parse(self, env, word):
        return word


class Mnemonic(Id):
    def __init__(self):
        super().__init__(None)


class Register(Asm, BitConstrained):
    def parse(self, env, word):
        word = env.unalias(word)
        valid_names = env.registers.names[:self.max_value]
        if word not in valid_names:
            raise SyntaxError('Register number exceeds available bits')
        return word


class Immediate(Asm, BitConstrained):
    def parse(self, env, word):
        word = env.unalias(word)
        try:
            imm = int(word, 0)
        except ValueError:
            # TODO replace with LUT. need to know current mnemonic / class
            imm = word
        else:
            if imm >= self.max_value:
                raise SyntaxError('Immediate exceeds available bits')
        return imm
