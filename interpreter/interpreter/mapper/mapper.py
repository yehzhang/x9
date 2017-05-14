class TokenMapper:
    """ Map a token in a language to a Python value. """

    def __init__(self, attr=None):
        self.attr = attr
        self.origin_attr = '_' + attr if attr else None

    def __or__(self, other):
        """
        :param TokenMapper other:
        :return InstructionMapper:
        """
        return InstructionMapper() | self | other

    def parse_and_set_attr(self, env, word, obj):
        """ Setting attribute is skipped during deserialization if not specified. """
        value = self.parse(env, word)
        if self.attr:
            setattr(obj, self.attr, value)
            setattr(obj, self.origin_attr, word)

    def get_attr_and_compose(self, env, obj):
        value = getattr(obj, self.attr, None)
        return self.compose(env, value)

    def tokenize(self, text):
        """
        :return str, str: remaining text, tokenized word
        """
        raise NotImplementedError

    def parse(self, env, word):
        """
        :return Any: parsed word
        """
        raise NotImplementedError

    def compose(self, env, value):
        """
        :return str: a component in target language
        """
        raise NotImplementedError


class InstructionMapper:
    """ Map an instruction in a language to an Instruction object. """

    def __init__(self):
        self.mappers = []

    def __or__(self, other):
        if isinstance(other, TokenMapper):
            self.mappers.append(other)
        elif isinstance(other, InstructionMapper):
            self.mappers.extend(other.mappers)
        else:
            assert False
        return self

    def deserialize(self, env, text, obj):
        for m in self.mappers:
            token, text = m.tokenize(text)
            if not token or (text and m is self.mappers[-1]):
                raise SyntaxError('Invalid number of operands')

            m.parse_and_set_attr(env, token, obj)

    def serialize(self, env, obj):
        """
        :return str: an instruction in target language
        """
        tokens = []
        for m in self.mappers:
            token = m.get_attr_and_compose(env, obj)
            if token:
                tokens.append(token)
        return ''.join(tokens)


class BitConstrained(TokenMapper):
    """ Mapper for the token whose value takes physical bits. """

    def __init__(self, attr, bits):
        super().__init__(attr)
        self.bits = bits
        self.max_value = bits ** 2
