from .mapper import TokenMapper, BitConstrained


class Asm(TokenMapper):
    def tokenize(self, text):
        segments = text.split(maxsplit=1)
        if len(segments) == 1:
            segments.append('')
        return segments

    def join(self, token, text):
        return token + ', ' + text


class Id(Asm):
    def parse(self, env, cls, word):
        return word


class Mnemonic(Id):
    def join(self, token, text):
        return token + ' ' + text


class Unaliasable(Asm, BitConstrained):
    def parse_constrained(self, env, cls, word):
        word = env.unalias(word)
        return self.parse_unaliased(env, cls, word)

    def parse_unaliased(self, env, cls, word):
        raise NotImplementedError


class Register(Unaliasable):
    def parse_unaliased(self, env, cls, word):
        try:
            return env.registers.names.index(word)
        except ValueError:
            raise SyntaxError('Invalid register name')


class Immediate(Unaliasable):
    pass


class LutKeyed(Immediate):
    def parse_unaliased(self, env, cls, word):
        lut_value = self.parse_lut_value(env, cls, word)
        acc_lut = env._acc_luts[cls.mnemonic]
        lut_key = acc_lut.setdefault(lut_value, len(acc_lut))
        env.luts[cls.mnemonic][lut_key] = lut_value
        return lut_key

    def parse_lut_value(self, env, cls, word):
        raise NotImplementedError


class LabelReference(LutKeyed):
    def parse_lut_value(self, env, cls, word):
        label = env.labels.get(word)
        if label is None:
            raise ValueError('Label name not found')
        return label.instruction_id


class MemoryAddress(LutKeyed):
    def parse_lut_value(self, env, cls, word):
        return int(word, 0)


class IntegerLiteral(Immediate):
    def parse_unaliased(self, env, cls, word):
        return int(word, 0)


class MemoryAddressOrIntegerLiteral(Asm):
    """ Geez it perfectly demonstrates how twisted the ISA is. """

    def __init__(self, attr, bits):
        super().__init__(attr)
        self.mem_addr_mapper = MemoryAddress(attr, bits)
        self.lit_mapper = IntegerLiteral(attr, bits)

    def parse(self, env, cls, word):
        mapper = self.lit_mapper if cls.mnemonic == 'set' else self.mem_addr_mapper
        return mapper.parse(env, cls, word)
