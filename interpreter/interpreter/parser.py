import os
import re
from tempfile import TemporaryFile
from subprocess import Popen, PIPE
from .statement import RegisterStatementFabric, Instruction
from .instructions import *


class Nano:
    TARGET_NAME = 'translator'

    def __init__(self, filename, env):
        self.filename = filename
        self.env = env

    def parse(self):
        """
        :return Tuple[List[Instruction], List[Label]]:
        """
        text = self.load_text()

        aliases = []
        labels = []
        insts = []
        i = 0
        for ln in text.splitlines():
            words = ln.split()
            inst_id, mnemonic = words[:2]
            args = words[2:]

            cls = RegisterStatementFabric.get(mnemonic)
            try:
                stmt = cls(inst_id, self.env, args)
            except Exception:
                raise ValueError("Invalid statement: '{}'".format(ln))

            stmts.append(stmt)


        return insts_sections

    def load_sections(self):
        pass

    def load_text(self):
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

        translator_path = os.path.join(nano_dir, self.TARGET_NAME)
        text = popen([translator_path, self.filename], 'Failed to parse')
        if text.startswith('Error: '):
            raise RuntimeError(text)
        return text
