# cordic_x9.s
define temp_cordic r3
define x_new1 r4
define x_new2 r5
define temp1 r6
define temp2_cordic r7
define t1 r8
define t2 r9
define i_cordic r10
define y1 r11
define y2 r12
define x1 r13
define x2 r14


# string_match_x9.s
define PATTERN_ADDR 9
define MAX_INT_ADDR 255

define RETURN_ADDR 10

define p_string r15
define slice r14
define count r13
define i_string r12
define j r11
define byte r10
define length r9
define bit r8
define pattern r7


# div_x9.s
define temp                 r3
define temp2                r4      #(shift_MSB),always 0
define temp3                r5      #(shift_LSB)
define quotient_MSW         r6      #(set)
define quotient_LSW         r7      #(set)
define div_MSW              r8      #(set)
define div_LSW              r9      #(set)
define divident_neg         r10     #(set)
define divisor_neg          r11     #(set)
define divident_temp_MSW    r12     #(set)
define divident_temp_LSW    r13     #(set)
define divisor_temp         r14     #(set)
define i                    r15

define DIVIDEND_ADDR_MSW 128
define DIVIDEND_ADDR_LSW 129
define DIVISOR_ADDR 130
define QUOTIENT_RETURN_ADDR_MSW 126
define QUOTIENT_RETURN_ADDR_LSW 127

define ONE 1
define SEVEN 7
define FIFTEEN 15





# cordic_x9.s
      # load x
      # 1(4bit MSW),2(8bits LSW)

      # load y
      # 3(4bit MSW),4(8bits LSW) is x

      # set immediate for t 12 bits
      set r0, 0
      set r1, 0
      add t1
      add t2
      add i_cordic


FORLOOP:
      #compare i_cordic with 12
      mov r1, i_cordic
      set r0, 11
      blts END:

      #compare if y is greater than 0
      set r1, 0
      lw r0, 1
      add x1
      lw r0, 2
      add x2
      lw r0, 3
      add y1
      lw r0, 4
      add y2


      mov r0, y1
      set r1, 0
      blts ELSE_ONLY:

      bne IF_ONLY:

      mov r0, y2
      set r1, 0
      blts ELSE_ONLY:

IF_ONLY:

      #x_new = x + (y>>i_cordic);
      srlc y1, y2, i_cordic, r2, temp_cordic # y1, y2 equal to after shifted values
      mov r0, temp_cordic
      mov r1, x2 # r1 = x2
      add x_new2 # x_new2 = y2+x2
      mov r0, r2
      mov r1, x1
      adc x_new1 # x_new1 = y1+x1+carry



      # y_new = y + ((-x)>>i_cordic);
      mov r0, x2
      neg r0  #r0 = -x2
      set r1, 1
      add temp2_cordic # add -x2+1, 2's complement
      mov r0, x1
      neg r0
      set r1, 0
      adc temp1 # temp1 = -x1+carry in case there is carrybit


      srlc temp1, temp2_cordic, i_cordic, r2, temp_cordic
      mov r0, temp_cordic
      mov r1, y2 # add y2+ ((-x)>>i_cordic)'s LSB
      add y2
      mov r1, y1
      mov r0, r2 # add y1+((-x)>>i_cordic)'s MSB
      adc y1

      # add r15

      #t_new = t + (1<<(11-i_cordic));
      set r0, 11
      mov r1, i_cordic
      sub temp1  #(11-i_cordic)

      set r0, 0
      set r1, 0
      add temp2_cordic
      set r0, 1
      add temp_cordic


      sllc temp2_cordic, temp_cordic, temp1, r2, temp_cordic # 0,1<<(11-i_cordic)

      mov r0, temp_cordic
      mov r1, t2
      add t2
      mov r1, t1
      mov r0, r2
      adc t1

      # add r15
      # go to assign parts
      set r0, 0
      set r1, 0
      beq ASSIGN:

ELSE_ONLY:
      #x_new = x + ((-y)>>i_cordic);
      mov r0, y2
      neg r0  #r0 = -y2
      set r1, 1
      add temp2_cordic # temp2_cordic = -x2+1
      mov r0, y1
      neg r0 # r0 = -y1
      set r1, 0
      add temp1 # temp1 = -x1+carru


      # -y>>i_cordic
      srlc temp1, temp2_cordic, i_cordic, r2, temp_cordic # temp1, temp1 equal to after shifted values
      mov r0, temp_cordic
      mov r1, x2 # r1 = x2
      add x_new2 # x_new2 = y2+x2
      mov r0, r2
      mov r1, x1
      adc x_new1 # x_new1 = y1+x1+carry



      # y_new = y + (x>>i_cordic);
      srlc x1, x2, i_cordic, r2, temp_cordic
      mov r0, temp_cordic
      mov r1, y2 # add y2+ ((x)>>i_cordic)'s LSB
      add y2
      mov r0, r2
      mov r1, y1 # add y1+((-x)>>i_cordic)'s MSB
      adc y1


      #t_new = t - (1<<(11-i_cordic));
      set r0, 11
      mov r1, i_cordic
      sub temp1  #(11-i_cordic)
      set r0, 0
      set r1, 0
      add temp2_cordic
      set r1, 1
      add temp_cordic
      sllc temp2_cordic, temp_cordic, temp1, r2, r0 # 1<<(11-i_cordic)

      #negate temp1, temp2_cordic
      neg r0 # negate 1<<(11-i_cordic) LSB
      set r1, 1
      add temp2_cordic # temp2_cordic = -1<<(11-i_cordic) LSB+1
      mov r0, r2
      neg r0
      set r1, 0
      adc temp1 # temp1 = -1<<(11-i_cordic) MSB

      # add together
      mov r0, t2
      mov r1, temp2_cordic
      add t2   # t2 = t2+(-1<<(11-i_cordic))LSB
      mov r0, t1
      mov r1, temp1
      adc t1    # t1 = t1+(-1<<(11-i_cordic))MSB


ASSIGN:
      #i_cordic++
      set r0,1
      mov r1, i_cordic
      add i_cordic
      # save new x1, x2 to 1 and 2 locs
      mov r0, x_new1
      mov r1, x_new2
      sw r0, 1
      sw r1, 2
      #save new y1, y2 to 3 and 4 locs
      mov r0, y1
      mov r1, y2
      sw r0, 3
      sw r1, 4

      # add r15

      # go back to for loop
      set r0, 0
      set r1, 0
      beq FORLOOP:

END:
      # store radian x
      lw r0, 1
      lw r1, 2
      sw r0, 5
      sw r1, 6
      #store theta t
      mov r0, t1
      mov r1, t2
      sw r0, 7
      sw r1, 8







# string_match_x9.s
    # char count = 0;
    set r0, 0
    set r1, 0
    add count

    # int i_string = 0;
    add i_string

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

    # unsigned char byte = p_string[i_string]  // i_string == 0
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

    # i_string++
    mov r0, i_string
    set r1, 1
    add i_string

    # byte = p_string[i_string];
    mov r0, i_string
    mov r1, p_string
    add r0
    lwr byte

    # do ... while (i_string < length);
    mov r0, i_string
    mov r1, length
    blt for_entry:
for_exit:

    mov r0, count
    sw r0, RETURN_ADDR






# div_x9.s
START:
    # quotient = 0;
    set r0, 0
    set r1, 0
    add quotient_MSW
    add quotient_LSW
    #if(divisor != 0){
    lw r0, DIVISOR_ADDR # good
    set r1, 0
    beq IF_EXIT
    #div = 0;
    set r0, 0
    set r1, 0
    add div_MSW
    add div_LSW

    #if(dividend >> 15 == 1){
    lw r0, DIVIDEND_ADDR_MSW # get most sig byte and shift by 7
    set r1, SEVEN
    srl r0
    set r1, 1
    bne FIRST_ELSE
    # divident_neg = 1;
    set r1, 1
    set r0, 0
    add divident_neg
    # divident_temp = ~dividend + 1;
    lw r0, DIVIDEND_ADDR_LSW
    neg r1
    lw r0, DIVIDEND_ADDR_MSW
    neg r2
    set r0, 1
    add divident_temp_LSW
    set r0, 0
    mov r1, r2
    adc divident_temp_MSW
FIRST_ELSE:
    # divident_neg = 0;
    set r0, 0 # good
    set r1, 0
    add divident_neg
    # divident_temp = dividend;
    lw r0, DIVIDEND_ADDR_LSW
    set r1, 0
    add divident_temp_LSW
    lw r0, DIVIDEND_ADDR_MSW
    add divident_temp_MSW  # good

    #second if
    # if(divisor >> 7 == 1){
    lw r0, DIVISOR_ADDR
    set r1, SEVEN
    srl r1
    set r0, 1
    bne SECOND_ELSE
    # divisor_neg = 1;
    set r0, 0
    set r1, 1
    add divisor_neg
    # divisor_temp = ~divisor + 1;
    lw r0, DIVISOR_ADDR
    neg r1
    set r0, 1
    add divisor_temp
SECOND_ELSE:
    # divisor_neg = 0;
    set r0, 0
    set r1, 0
    add divisor_neg
    # divisor_temp = divisor;
    lw r1, DIVISOR_ADDR
    set r0, 0
    add divisor_temp

    # int i = 0;
    set r0, 0
    set r1, 1
    sub r0
    set r1, 0
    add i

FOR_LOOP_START:
    # i++
    mov r0, i
    set r1, 1
    add i

    # int shift = 15 - i;
    set r0, FIFTEEN
    mov r1, i
    sub temp3 # shift_LSB   # good
    set r0, 0
    set r1, 0
    add temp2 # shift_MSB    # good
    # shift = divident_temp >> shift;
    srlc divident_temp_MSW, divident_temp_LSW, temp3, r0, r2

    # shift = shift & 1;
    mov r1, r2
    set r0, 1
    and temp3
    set r0, 0
    set r1, 0
    add temp2
    # int div = div << 1;
    set r0, 1
    set r1, 0
    add temp
    sllc div_MSW, div_LSW, temp, div_MSW, div_LSW


    # div = div + shift;
    mov r0, temp3
    mov r1, div_LSW
    add div_LSW
    set r0, 0
    mov r1, div_MSW
    adc div_MSW


    # if(div >= divisor_temp){ # third if
    # r3,r4,r5 are free to use now
    # compare upper MSB with 0
    mov r0, div_MSW
    set r1, 0
    blts THIRD_ELSE
    # if MSB is same，both 0,compare LSB
    mov r0, div_LSW
    mov r1, divisor_temp
    blts THIRD_ELSE
    # div = div - divisor_temp;
    # first: extend bit for divisor_temp
    set r0, 0
    set r1, 0
    add temp2 # temp2 holds MSB for extend_divisor_temp
    set r0, 0
    mov r1, divisor_temp # LSB
    beq EXTEND_BIT_COMPELET
    blt EXTEND_BIT_COMPELET
    set r0, 0
    neg temp2
EXTEND_BIT_COMPELET:
    # negate temp2, and divisor_temp into temp2, temp3
    # then add 1 to both
    mov r0, divisor_temp
    neg temp3
    mov r0, temp2
    neg temp2
    set r1, 1
    mov r0, temp3
    add temp3
    mov r0, temp2
    set r1, 0
    adc temp2
    # finally, div = div + (- divisor_temp);
    mov r0, div_LSW
    mov r1, temp3
    add div_LSW
    mov r1, div_MSW
    mov r1, temp2
    adc div_MSW
    # quotient = (quotient << 1);
    set r0, 1
    set r1, 0
    add r3
    # set r1, 28 #NOP
    sllc quotient_MSW, quotient_LSW, r3, quotient_MSW, quotient_LSW

    # set r1, 28 #NOP
    # quotient = quotient + 1;
    mov r0, quotient_LSW
    set r1, 1
    add quotient_LSW
    mov r0, quotient_MSW
    set r1, 0
    adc quotient_MSW

    # set r1, 28 #NOP

    set r0, 0
    set r1, 0
    beq CHECK_I

THIRD_ELSE:
    # quotient = (quotient << 1);
    set r0, 1
    set r1, 0
    add r3
    sllc quotient_MSW, quotient_LSW, r3, quotient_MSW, quotient_LSW

CHECK_I:
    # time to check i
    set r0, FIFTEEN
    mov r1, i
    bne FOR_LOOP_START

    # end of for loop
    # if(divident_neg != divisor_neg){
    mov r0, divident_neg
    mov r1, divisor_neg
    beq IF_EXIT
    # quotient = ~quotient + 1
    mov r0, quotient_LSW
    neg r1
    mov r0, quotient_MSW
    neg r2
    set r0, 1
    add quotient_LSW
    set r0, 0
    mov r1, r2
    adc quotient_MSW
IF_EXIT:
    # store back into 126(MSW), 127(LSW)
    mov r0, quotient_MSW
    mov r1, quotient_LSW
    sw r0, QUOTIENT_RETURN_ADDR_MSW
    sw r1, QUOTIENT_RETURN_ADDR_LSW
