import re

def main():
    REPL = {
        'string': '$a0',
        'length': '$a1',
        'pattern': '$a2',
        'count': '$s0',
        'slice': '$s1',
        'total_bits': '$s2',
        'i': '$s3',
        'byte': '$s4',
        'bit': '$s5',
        'nop': 'add $t0, $zero, $t0',
    }

    with open('string_match.s') as fin:
        text = fin.read()
    for k, v in REPL.items():
        text = re.sub(r'\b{}\b'.format(k), v, text)
    text = re.sub(r'(?<=, )(\w+):', r'\1', text)


    print(text)

if __name__ == '__main__':
    main()
