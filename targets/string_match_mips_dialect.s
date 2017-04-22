# int bytes_match(char *string, int length, char pattern)
# $a0: char *string
# $a1: int length
# $a2: char pattern
# $s0: int count
# $s1: char slice
# $s2: int total_bits
# $s3: int i
# $s4: char byte
# $s5: char bit

# # char string[] = { 0b01001010, 0b10010100, 0b00010001, 0b01010000 };
# p_string: .byte 74, 148, 17, 80
#     addi $sp, $sp, -4
#     addi $t0, $zero, 74
#     sb $t0, 0($sp)
#     addi $t0, $zero, 148
#     sb $t0, 1($sp)
#     addi $t0, $zero, 17
#     sb $t0, 2($sp)
#     addi $t0, $zero, 80
#     sb $t0, 3($sp)
#     add $a0, $sp, $zero

#     # length = 4
#     addi $a1, $zero, 4

#     # char pattern = 0b0101;
#     addi $a2, $zero, 5


    # if (length == 0) return 0;
    add $v0, $zero, $zero
    beq length, $zero, return:
    nop

    # int count = 0;
    add count, $zero, $zero

    # char slice = string[0] >> 5;
    lbu $t0, 0(string)
    srl slice, $t0, 5

    # int total_bits = length * 8;
    sll total_bits, length, 3

    # for (int i = 3; i < total_bits; i++)
    addi i, $zero, 3
for_entry:
    slt $t0, i, total_bits
    beq $t0, $zero, for_exit:
    nop

        # char byte = string[i / 8];
        srl $t0, i, 3
        add $t0, string, $t0
        lbu byte, $t0

        # char bit = (byte >> (7 - i % 8)) & 1;
        addi $t0, $zero, 7 # = 0b111
        and $t0, i, $t0 # i % 8
        sub $t0, $zero, $t0 # - i % 8
        addi $t0, $t0, 7 # 7 - i % 8
        srlv $t0, byte, $t0 # byte >> (7 - i % 8)
        addi $t1, $zero, 1
        and $t0, $t1, $t0
        move bit, $t0

        # slice = ((slice << 1) & 0b1111) | bit;
        sll $t0, slice, 1 # (slice << 1)
        addi $t1, $zero, 15 # = 0b1111
        and $t0, $t1, $t0 # (slice << 1) & 0b1111
        or slice, bit, $t0

        # if (slice == pattern) count++;
        bne slice, pattern, inc_count_footer:
        nop
        # TODO Better have a set instruction
        addi count, count, 1
inc_count_footer:

        # if (count >= 255) break;
        # Saturated
        addi $t0, $zero, 255
        bne count, $t0, for_exit:
        nop

    addi i, i, 1
    j for_entry
for_exit:

return:
