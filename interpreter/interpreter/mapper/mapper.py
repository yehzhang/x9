from ..environment import convert_to_unsigned_integer


class TokenMapper:
    """ Map a token in a language to a Python value.
    :param str|None attr: The name of an attribute of an object mapped with this token.
        If None, the object is unmodified during deserialization and nothing is produced during
        serialization.
    """

    def __init__(self, attr=None):
        self.attr = attr
        self.src_attr = self._to_src_attr_name(attr) if attr else None

    def __or__(self, other):
        """
        :param TokenMapper other:
        :return InstructionMapper:
        """
        return InstructionMapper() | self | other

    def __and__(self, other):
        """
        :param TokenMapper other:
        :return InstructionMapper:
        """
        return self | InstructionSeparator() | other

    def parse_and_set_attr(self, env, word, obj):
        """ Setting attribute is skipped during deserialization if attr is not specified. """
        value = self.parse(env, type(obj), word)

        if self.attr:
            setattr(obj, self.attr, value)
            setattr(obj, self.src_attr, word)

    def get_attr_and_compose(self, env, obj):
        """ Getting attribute is skipped during serialization if attr is not specified. """
        if self.attr is None:
            value = None
        else:
            value = getattr(obj, self.src_attr, None)
            if value is not None:
                return value

            value = getattr(obj, self.attr, None)

        return self.compose(env, value)

    def tokenize(self, text):
        """
        :return str, str: remaining text, tokenized word
        """
        raise NotImplementedError

    def parse(self, env, cls, word):
        """
        :return Any: parsed word
        """
        raise NotImplementedError

    def compose(self, env, value):
        """
        :return str: a component in target language
        """
        raise NotImplementedError

    def join(self, token, text):
        """
        :param str token: token tokenized by this mapper
        :param str text: the following text
        :return str:
        """
        raise NotImplementedError

    @classmethod
    def _to_src_attr_name(cls, attr):
        return '_src_{}_{}'.format(cls.__qualname__, attr)


class InstructionMapper:
    """ Map an instruction in a language to an Instruction object. """

    def __init__(self):
        self.mappers = []

    def __or__(self, other):
        """ Combine two mappers of an instruction
        :param TokenMapper other:
        :return InstructionMapper:
        """
        if isinstance(other, TokenMapper):
            self.mappers.append(other)
        elif isinstance(other, InstructionMapper):
            self.mappers.extend(other.mappers)
        else:
            assert False
        return self

    def __and__(self, other):
        """ Concatenate mappers of two instructions
        :param TokenMapper other:
        :return InstructionMapper:
        """
        return self | InstructionSeparator() | other

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
        text = None
        for m in reversed(self.mappers):
            token = m.get_attr_and_compose(env, obj)
            if token is None:
                continue
            if text is None:
                text = token
            else:
                text = m.join(token, text)
        return text


class BitConstrained(TokenMapper):
    """ Mapper for the token whose value takes physical bits. """

    def __init__(self, attr, bits):
        super().__init__(attr)
        self.bits = bits
        self.upper_bound = 2 ** bits

    def parse(self, env, cls, word):
        """
        :return int:
        """
        value = self.parse_constrained(env, cls, word)
        if convert_to_unsigned_integer(value, self.bits) >= self.upper_bound:
            raise ValueError('Value of token exceeds available bits')
        return value

    def parse_constrained(self, env, cls, word):
        """
        :return int:
        """
        raise NotImplementedError


class InstructionSeparator(TokenMapper):
    """ Convert an Instruction object to multiple instructions in the target language.
    Note that the conversion is not injective, meaning that the converted instructions
    cannot be mapped back to the original Instruction object, possibly multiple objects
    instead.
    """
    def __init__(self, sep='\n'):
        super().__init__(None)
        self.sep = sep

    def compose(self, env, value):
        return ''

    def join(self, token, text):
        """
        :param str token: should be the '' returned by compose
        """
        return token + self.sep + text
