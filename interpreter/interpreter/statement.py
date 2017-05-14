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
        return mcs.insts[ref_name]


class Statement(metaclass=RegisterStatementFabric):
    mnemonic = None
    asm_mapper = None
    machine_code_mapper = None

    def __init__(self, instruction_id, env):
        self.instruction_id = instruction_id
        self.env = env

    @classmethod
    def new_instance(cls, src, instruction_id, env, text):
        obj = cls(instruction_id, env)
        mapper = getattr(cls, src + '_mapper')
        mapper.deserialize(env, text, obj)
        return obj

    def as_code(self, target):
        mapper = getattr(self, target + '_mapper')
        return mapper.serialize(self.env, self)

    def __repr__(self):
        return '<{} {}>'.format(type(self).__name__, self.mnemonic)


class Label(Statement):
    mnemonic = 'label'
    asm_mapper = asm.Mnemonic() | asm.Id('name')
