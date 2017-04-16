import re
from .instructions import RegisterInstructionFabric, Executable

class InstructionParser:
    MNEMONIC_PATTERN = re.compile(r'\s*(\w+)\s*(.*)')
    REGS_MAPPING = {
        '$0': 0,
        '$1': 1,
        '$2': 2,
        '$3': 3
    }

    @classmethods
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
            name, args = matched.group(1, 2)

            # TODO
            # inst_cls = RegisterInstructionFabric.get(name)
            # inst_cls()

            # args

            dest = execs if isinstance(inst_cls, Executable) else labels
            dest.append(inst)

        return execs, labels
