# lw LUT:
# STRING_LENGTH = 64

STRING_ADDR_KEY = 90
STRING_LENGTH_KEY = 64

I_ADDR = ??

p_string = s0
pattern = s1
slice = s2
count = s3
i_lo = s4
i_hi = s5

byte = t0
bit = t1

    # char count = 0;
    set 0
    mov r1, r0
    add count

    # char slice = p_string[0] >> 5;
    # byte = p_string[0]
    lw STRING_ADDR_KEY
    add p_string
    lwr byte
    set 5
    mov r1, r0
    # slice = byte >> 5
    mov r0, byte
    srl slice

    # int total_bits = STRING_LENGTH * 8;
    lw STRING_LENGTH_KEY
    mov r1, r0
    # TODO sllc 2 bytes
    lw STRING_LENGTH_KEY
    set 3
    sllc total_bits  # need to use special instruction because total_bits is 512

    # for (int i = 3; i < total_bits; i++)
    set 3
    mov r1, zero
    set I_ADDR
    sw r1, r0
for_entry:
    # i < total_bits;
    set I_ADDR
    mov r1, r0
    set TOTAL_BITS_ADDR
    mov temp2, r0
    sltc r1, r0
    beq r0, r1, for_exit:

        # char byte = p_string[i / 8];
        set 3
        mov r1 r0
        mov r0 i
        srl r1
        add r1
        mov r0, p_string
        add r0
        lwr byte

        # char bit = (byte >> (7 - i % 8)) & 1;
        set 7
        mov r1, r0
        mov r0, i
        and r1  # i % 8
        set 0
        sub r1  # - i % 8
        set 7
        sub r1 # 7 - i % 8
        mov r0 byte
        srl r1 # byte >> (7 - i % 8)
        set 1
        and bit

        # slice = ((slice << 1) & 0b1111) | bit;
        set 1
        mov r1, r0
        mov r0, slice
        sll r1  # slice << 1
        set 0b1111
        and r1  # (slice << 1) & 0b1111
        mov r0, bit
        or slice

        # if (slice == pattern) count++;
        mov r0, slice
        mov r1, pattern
        bne inc_count_footer:
        # TODO Better have a set instruction
        set 1
        mov r1, count
        add count
    inc_count_footer:

        # if (count >= 255) break;
        # Saturated
        lw BYTE_MAX_VAL
        mov r1, r0
        mov r0, count
        slt r1
        set 0
        beq for_exit:

    # i++
    set 1
    mov r1, i
    add i
    set 0
    mov r1, r0
    beq for_entry:
for_exit:

    mov r0, count
    sw RETURN_ADDR
