import re
from .instructions import RegisterInstructionFabric, Executable

class InstructionParser:
    MNEMONIC_PATTERN = re.compile(r'\s*(\w+)\s*(.*)')
    ARGS_PATTERN = re.compile(r'\s*,\s*')
    REGS_MAPPING = {
        '$0': 0,
        '$1': 1,
        '$2': 2,
        '$3': 3
    }

    @classmethod
    def parse(cls, text):
        """
        :return Tuple[List[Executable], List[Label]]:
        """
        execs = []
        lables = []

        for i, ln in enumerate(text.split()):
            matched = cls.MNEMONIC_PATTERN.match(ln)
            if matched is None:
                raise SyntaxError('Invalid instruction: {}'.format(type(ln)))
            name, args_str = matched.group(1, 2)

            inst_cls = RegisterInstructionFabric.get(name)

            arg_strs = cls.ARGS_PATTERN.split(args_str)
            args = []
            for arg in arg_strs:
                i_reg = cls.REGS_MAPPING.get(arg)
                if i_reg is None:
                    # TODO handle immediate if number else syntax error
                    raise NotImplementedError
                args.append(i_reg)

            inst = inst_cls(*args)

            dest = execs if isinstance(inst, Executable) else labels
            dest.append(inst)

        return execs, labels

class InstructionParser:

    def __init__(self):
        pass
