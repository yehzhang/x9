import os
import re
from tempfile import TemporaryFile
from subprocess import Popen, PIPE
from .statement import RegisterStatementFabric, Instruction


class Nano:

    @classmethod
    def parse(cls, filename, env):
        """
        :return Tuple[List[Instruction], List[Label]]:
        """
        this_dir = os.path.dirname(__file__)
        nano_dir = os.path.join(this_dir, './nano')
        cls.popen(['make', '-C', nano_dir], 'Failed to compile parser')

        translator_path = os.path.join(nano_dir, 'translator')
        text = cls.popen([translator_path, filename], 'Failed to parse')

        insts = []
        for ln in text.splitlines():
            words = ln.split()
            inst_id, mnemonic = words[:2]
            args = words[2:]

            cls = RegisterStatementFabric.get(mnemonic)
            stmt = cls(inst_id, env, *args)

            insts.append(stmt)
        return insts

    @classmethod
    def popen(cls, args, err_msg):
        with Popen(args, stdout=PIPE, stderr=PIPE) as proc:
            proc.wait()
            stdout = proc.stdout.read().decode()
            if proc.returncode != 0:
                stderr = proc.stderr.read().decode()
                raise RuntimeError('{}: \n{}\n{}'.format(err_msg, stdout, stderr))
        return stdout
