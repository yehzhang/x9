define PATTERN_ADDR 9
define MAX_INT_ADDR 255

define RETURN_ADDR 10

define p_string r15
define slice r14
define count r13
define i r12
define j r11
define byte r10
define length r9
define bit r8
define pattern r7

    # char count = 0;
    set r0, 0
    set r1, 0
    add count

    # int i = 0;
    add i

    # unsigned char pattern = *PATTERN_ADDR
    lw r0, PATTERN_ADDR
    add pattern

    # int j = 4;
    set r0, 4
    add j

    # int length = 64;
    set r0, 1
    set r1, 6
    sll length

    # unsigned char *p_string = 32;
    set r1, 5
    sll p_string

    # unsigned char byte = p_string[i]  // i == 0
    mov r0, p_string
    lwr byte

    # char slice = p_string[0] >> 5;
    mov r0, byte
    srl slice

    # do
for_entry:
        # do
    inner_for_entry:
        # char bit = (byte >> j) & 1;
        mov r0, byte
        mov r1, j
        srl r0
        set r1, 1
        and bit

        # slice = ((slice << 1) & 0b1111) | bit;
        mov r0, slice
        sll r0
        set r1, 0b1111
        and r0
        mov r1, bit
        or slice

        # if (slice == pattern) count++;
        mov r0, slice
        mov r1, pattern
        bne failed_to_match:
        mov r0, count
        set r1, 1
        add count

        # if (count == 255) return count;
        mov r0, count
        lw r1, MAX_INT_ADDR
        beq for_exit:
    failed_to_match:

        # j--
        mov r0, j
        set r1, 1
        sub j

        # do ... while (j >= 0)
        set r0, 0
        mov r1, j
        blts inner_for_entry:
        beq inner_for_entry:

    # j = 7
    set r1, 7
    add j

    # i++
    mov r0, i
    set r1, 1
    add i

    # byte = p_string[i];
    mov r0, i
    mov r1, p_string
    add r0
    lwr byte

    # do ... while (i < length);
    mov r0, i
    mov r1, length
    blt for_entry:
for_exit:

    mov r0, count
    sw r0, RETURN_ADDR
    halt r0
