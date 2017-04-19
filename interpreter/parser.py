import os
import re
from tempfile import TemporaryFile
from subprocess import Popen, PIPE
from .statement import RegisterStatementFabric, Instruction


class Nano:
    TARGET_NAME = 'translator'

    @classmethod
    def parse(cls, filename, env):
        """
        :return Tuple[List[Instruction], List[Label]]:
        """

        text = cls.load_text(filename)
        sections = text.split('\n\n')

        insts_sections = []
        for section in sections:
            insts = []
            for ln in section.splitlines():
                words = ln.split()
                inst_id, mnemonic = words[:2]
                args = words[2:]

                cls = RegisterStatementFabric.get(mnemonic)
                inst_id = int(inst_id)
                stmt = cls(inst_id, env, *args)

                insts.append(stmt)

            insts_sections.append(insts)

        return insts_sections

    @classmethod
    def load_text(cls, filename):
        def popen(args, err_msg):
            with Popen(args, stdout=PIPE, stderr=PIPE) as proc:
                proc.wait()
                stdout = proc.stdout.read().decode()
                if proc.returncode != 0:
                    stderr = proc.stderr.read().decode()
                    raise RuntimeError('{}:\n{}{}'.format(err_msg, stdout, stderr))
            return stdout

        this_dir = os.path.dirname(__file__)
        nano_dir = os.path.join(this_dir, './nano')
        popen(['make', '-C', nano_dir], 'Failed to compile parser')

        translator_path = os.path.join(nano_dir, cls.TARGET_NAME)
        text = popen([translator_path, filename], 'Failed to parse')
        if text.startswith('Error: '):
            raise RuntimeError(text)
        return text
