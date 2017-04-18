class Envrionment:

    def __init__(self, config):
        self.registers = make_registers(self, config)
        self.memory = [config['mem_default_value']] * config['mem_size']
        self.labels = {}
        self.should_exit = False

    def __str__(self):
        return str(self.registers)

    def tick(self):
        """ Update states in a clock cycle. """
        self.registers.pc = self.registers.fetch_maybe_updated_pc() + 1

    def exit(self):
        """ Called by instruction to exit """
        self.should_exit = True


def make_registers(env, config):
    class Registers:

        def __init__(self, env, config):
            self.mapping = config['reg_mapping']
            self.registers = [config['reg_default_value']] * len(self.mapping)
            self.env = env
            self.max_val = config['reg_max_value']
            self.next_pc = None

        def __str__(self):
            rev_mapping = {v: k for k, v in self.mapping.items()}
            regs_str = '\n'.join('\t{}: 0x{:02x}'.format(rev_mapping[i], reg)
                                 for i, reg in enumerate(self.registers))
            return 'registers: \n{}'.format(regs_str)

        def get_index(self, reg_name):
            i = self.mapping.get(reg_name)
            if i is None:
                raise ValueError('Register {} does not exist'.format(repr(reg_name)))
            return i

        def update_pc(self, addr):
            """ Set the value of pc in next clock cycle """
            if self.next_pc is not None:
                raise RuntimeError("Register 'pc' is already set in this clock cycle")
            if not isinstance(addr, int):
                raise RuntimeError("Invalid pc address")
            self.next_pc = addr

        def fetch_maybe_updated_pc(self):
            """ Get next pc if set or current.
                Called each clock cycle to update pc
            """
            if self.next_pc is not None:
                next_pc = self.next_pc
                self.next_pc = None
            else:
                next_pc = self.pc
            return next_pc


    for name, idx in config['reg_mapping']:
        setattr(Registers, name, GetItemProperty('registers', idx))

    return Registers(env, config)


class GetItemProperty:

    def __init__(self, data_attr_name, idx):
        self._name = data_attr_name
        self._idx = idx

    def __get__(self, obj, cls):
        return getattr(obj, self._name)[self._idx]

    def __set__(self, obj, value):
        getattr(obj, self._name)[self._idx] = value


def new_storage_list(size, default=None):
    raise NotImplementedError
