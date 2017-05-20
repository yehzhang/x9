from .parser import Nano
from .interpreter import Environmental
import os.path

class Assembler(Environmental):
    def __init__(self, config=None):
        super().__init__(config)
        self.insts = None

    def load(self, filename):
        self.insts = Nano(filename, self.env).parse()
        return self


    def run(self, out_dir):
        ''' execute instructions '''
        if self.insts is None:
            raise RuntimeError('Assembly file is not loaded')
        if out_dir is None:
            raise RuntimeError('Save directory is not specified')

        m_code = []
        for inst in self.insts:
            m_code.append(inst.as_code('machine_code'))

        self.save(m_code, out_dir)


    def save(self, m_code, dir):
        ''' save machine code to specific location '''
        tbs = '\n'.join(m_code)
        save_path = os.path.join(dir, 'machine_code.txt')
        file = open(save_path, 'w')
        file.write(tbs)
        file.close()

