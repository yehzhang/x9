import re


def reg_name(match):
    v = int(match.group()[1:])
    if v == 0:
        return '$zero'
    if v == 1:
        return '$at'
    if v <= 3:
        return '$v{}'.format(v - 2)
    if v <= 7:
        return '$a{}'.format(v - 4)
    if v <= 15:
        return '$t{}'.format(v - 8)
    if v <= 23:
        return '$s{}'.format(v - 16)
    if v <= 25:
        return '$t{}'.format(v - 16)
    if v <= 27:
        return '$k{}'.format(v - 26)
    return {
        28: '$gp',
        29: '$sp',
        30: '$fp',
        31: '$ra',
    }[v]


new_lns = []
pattern = re.compile(r'\$\d+')

with open('test.s') as fin:
    for ln in fin:
        new_ln = pattern.sub(reg_name, ln)
        new_lns.append(new_ln)

text = ''.join(new_lns)
text = text.replace(',', ', ')
print(text)
