import os
from subprocess import Popen, PIPE

from .statement import RegisterStatementFabric, Label
from .instruction import *


class Nano:
    TARGET_NAME = 'translator'

    def __init__(self, filename, env):
        self.filename = filename
        self.env = env

    def parse(self):
        """
        :return Tuple[List[Label], List[Instruction]]:
        """
        # TODO LUTs
        print(self.load_sections(self.filename))
        a_sec, s_sec = self.load_sections(self.filename)

        # Construct aliases
        for a in a_sec:
            _, s, t = a.split()
            self.env.aliases[s] = t

        # Parse and check statements
        labels = []
        insts = []
        i_ln = 0
        for s in s_sec:
            mne, _ = s.split(maxsplit=1)
            try:
                cls = RegisterStatementFabric.get(mne)
                stmt = cls.new_instance('asm', i_ln, self.env, s)
            except Exception:
                raise SyntaxError('Invalid statement: ' + repr(s))

            if isinstance(stmt, Label):
                labels.append(stmt)
            else:
                insts.append(stmt)
                i_ln += 1

        return labels, insts

    @classmethod
    def load_sections(cls, filename):
        """
        :return List[List[str]]
        """
        text = cls.load_translation(filename)
        return [sec.splitlines() for sec in text.split('\n\n')]

    @classmethod
    def load_translation(cls, filename):
        """
        :return str:
        """
        this_dir = os.path.dirname(__file__)
        nano_dir = os.path.join(this_dir, './nano')
        cls.popen(['make', '-C', nano_dir], 'Failed to compile parser')

        translator_path = os.path.join(nano_dir, cls.TARGET_NAME)
        text = cls.popen([translator_path, filename], 'Failed to parse')
        if text.startswith('Error: '):
            raise RuntimeError(text)
        return text

    @staticmethod
    def popen(args, err_msg):
        with Popen(args, stdout=PIPE, stderr=PIPE) as proc:
            proc.wait()
            stdout = proc.stdout.read().decode()
            if proc.returncode != 0:
                stderr = proc.stderr.read().decode()
                raise RuntimeError('{}. Parser message:\n\t{}{}'.format(err_msg, stdout, stderr))
        return stdout
