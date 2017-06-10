import os

from .interpreter import Environmental
from .parser import Nano


class Assembler(Environmental):
    SV_LUT_TEMPLATE = '''\
// parameters used in the LUT
package LUT_def;
    // LUT index
    typedef enum {{
{}
    }} LUT_TYPE;

    // LUT[opcode][imm] => value
    const logic[7:0] kLookupTable[6][32] = {};
endpackage
'''
    SV_ARR_TEMPLATE = "'{{{}}}"
    WATERMARK = '// Generated by x9-assembler'
    LUT_CAPACITY = 32

    def __init__(self, config=None):
        super().__init__(config)
        self.insts = None

    def load(self, filename):
        self.insts = Nano(filename, self.env).parse()
        return self

    def run(self, out_dir):
        """ execute instructions """
        if self.insts is None:
            raise RuntimeError('Assembly file is not loaded')
        if out_dir is None:
            raise RuntimeError('Save directory is not specified')
        out_dir = os.path.abspath(os.path.expanduser(out_dir))
        os.makedirs(out_dir, exist_ok=True)

        # Save machine code
        text = '\n'.join(inst.as_code('machine_code') for inst in self.insts)
        self.save(text, out_dir, 'machine_code.txt')

        # Save LUT definitions
        text = self.serialize_luts(self.env)
        self.save(text, out_dir, 'LUT_def.sv')

    @classmethod
    def save(cls, text, dir, filename):
        """ Save generated text to specific location. """
        save_path = os.path.join(dir, filename)
        text = '\n'.join([cls.WATERMARK, text])
        with open(save_path, 'w') as fout:
            fout.write(text)

    @classmethod
    def serialize_luts(cls, env):
        types = []
        luts = []
        for i, (mne, lut) in enumerate(env.luts.items()):
            types.append((mne, i))
            luts.append((i, lut))

        type_def = ', \n'.join('LUT_{} = {}'.format(m.upper(), i) for m, i in types)

        lut_defs = []
        cls.SV_ARR_TEMPLATE.format
        for i, lut in luts:
            lut = [str(lut.get(i, 0)) for i in range(cls.LUT_CAPACITY)]
            lut = cls.SV_ARR_TEMPLATE.format(', '.join(lut))
            lut_defs.append(lut)
        joined_luts = ', \n'.join(lut_defs)
        tables_def = cls.SV_ARR_TEMPLATE.format('\n{}\n'.format(joined_luts))

        return cls.SV_LUT_TEMPLATE.format(type_def, tables_def)
