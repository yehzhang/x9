import os
from subprocess import Popen, PIPE

from .statement import RegisterStatementFabric, Label


class Nano:
    TARGET_NAME = 'translator'

    def __init__(self, filename, env):
        self.filename = filename
        self.env = env

    def parse(self):
        """
        :return List[Instruction]:
        """
        a_sec, s_sec = self.load_sections(self.filename)

        self.populate_aliases(a_sec)

        # Parse, instantiate, and check statements
        inst_asms = []
        i_ln = 0
        s = None
        try:
            for s in s_sec:
                mne, _ = s.split(maxsplit=1)
                cls = RegisterStatementFabric.get(mne)
                # Register all labels before any instruction
                if cls is Label:
                    label = cls.new_instance('asm', i_ln, self.env, s)
                    self.env.labels[label.name] = label
                else:
                    inst_asms.append((i_ln, cls, s))
                    i_ln += 1

            insts = []
            for (i_ln, cls, s) in inst_asms:
                inst = cls.new_instance('asm', i_ln, self.env, s)
                insts.append(inst)
            return insts
        except Exception:
            raise SyntaxError('Invalid statement: ' + repr(s))

    def populate_aliases(self, section):
        aliases = self.env.aliases
        for a in section:
            _, s, t = a.split()
            if s in aliases:
                raise ValueError('Alias conflicts: ' + repr(s))
            aliases[s] = t

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
