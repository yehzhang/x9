import pytest


def test_answer():
    from interpreter.environment import Memory

    mem = Memory({
        'mem_default': 0,
        'mem_size': 64,
    })

    mem[1, 2] = 0xf000
    assert mem[0, 3] == 0xf000
    assert mem.load(0, 3, True) == 0xf000
    assert mem.load(0, 2, True) == 0xf0
    assert mem.load(1, 1, False) == 0xf0
    assert mem.load(1, 1, True) == -16

    mem[0, 4] = 123
    assert mem[0, 4] == 123
    assert mem.load(0, 4, True) == 123

    mem[0, 4] = -123
    assert mem[0, 4] == 4294967173
    assert mem.load(0, 4, True) == -123
    assert mem.load(0, 5, True) == -31488
    assert mem.load(1, 5, True) == -8060928
    assert mem.load(1, 3, True) == -123
    assert mem.load(2, 2, True) == -123
    assert mem.load(3, 1, True) == -123
    assert mem.load(0, 3, True) == -1
    assert mem.load(0, 2, True) == -1
    assert mem.load(0, 1, True) == -1

    mem[0, 4] = -256
    assert mem.load(0, 3, True) == -1
    assert mem.load(3, 2, True) == 0

    with pytest.raises(ValueError):
        mem[0, 2] = 0x10000
    assert mem[0, 4] == 4294967040
