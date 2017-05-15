from .mapper import asm


class RegisterStatementFabric(type):
    """Register classes of statements."""
    insts = {}

    def __new__(mcs, name, bases, nmspc):
        cls = super().__new__(mcs, name, bases, nmspc)

        ref_name = getattr(cls, 'mnemonic')
        if ref_name is not None:
            if ref_name not in mcs.insts:
                mcs.insts[ref_name] = cls

                # TODO Sanity check of duplicate (opcode, funct)?

        return cls

    @classmethod
    def get(mcs, ref_name):
        cls = mcs.insts.get(ref_name)
        if cls is None:
            raise ValueError('Unknown statement name')
        return cls


class Statement(metaclass=RegisterStatementFabric):
    mnemonic = None

    # Add mappers here to support more languages
    asm_mapper = None
    machine_code_mapper = None

    def __init__(self, instruction_id, env):
        self.instruction_id = instruction_id
        self.env = env
        self.init_attrs()

    def init_attrs(self):
        """ Subclasses overwrites this method to initialize attributes. """
        raise NotImplementedError

    @classmethod
    def new_instance(cls, src, instruction_id, env, text):
        obj = cls(instruction_id, env)
        mapper = getattr(cls, src + '_mapper', None)
        if mapper is None:
            raise NotImplementedError('Mapper is not supported')
        mapper.deserialize(env, text, obj)
        return obj

    def as_code(self, target):
        mapper = getattr(self, target + '_mapper', None)
        if mapper is None:
            raise NotImplementedError('Mapper is not supported')
        return mapper.serialize(self.env, self)

    def __repr__(self):
        return '<{} {}>'.format(type(self).__name__, self.mnemonic)


class Label(Statement):
    mnemonic = 'label'

    asm_mapper = asm.Mnemonic() | asm.Id('name')

    def init_attrs(self):
        self.name = None
