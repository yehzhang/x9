# dividend 1000 // 16 bit at memory  128, 129
# divisor 3; //8 bit at memory 130
# r3 = temp
# r4 = i
# r5 = temp
# r6 = quotient 0; (MSW)
# r7 = quotient 0; (LSW)
# r8 = div 0; (MSW)
# r9 = div 0; (LSW)
# r10 = divident_neg 0;
# r11 = divisor_neg 0;
# r12 = divident_temp 0; (MSW)
# r13 = divident_temp 1; (LSW)
# r14 = divisor_temp 0;
# r15 = temp


#Look Up Table (0-31)
# Entry --  Address
# 0     --  128   -- DIVIDEND_ADDR_0  (MSW)
# 1     --  129   -- DIVIDEND_ADDR_1  (LSW)
# 2     --  130   --  DIVISOR_ADDR
# 3     --  131   -- ONE_ADDR (just number 1 or 0)

#Branch Table(0-31)
# IF_EXIT
# FIRST_ELSE
# SECOND_ELSE
# FOR_LOOP_START
# THIRD_ELSE

define temp                 r3
define temp2                r4      
define temp3                r5      #(shift)
define quotient_MSW         r6      #(set)
define quotient_LSW         r7      #(set)
define div_MSW              r8      #(set)
define div_LSW              r9      #(set)
define temp4          r10     #(set)
define temp5          r11     #(set)
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

    # divident_temp = dividend;
    lw r0, DIVIDEND_ADDR_LSW
    set r1, 0
    add divident_temp_LSW
    lw r0, DIVIDEND_ADDR_MSW
    add divident_temp_MSW  

    # divisor_temp = divisor;
    lw r1, DIVISOR_ADDR
    set r0, 0
    add divisor_temp

    # int i = -1;
    set r0, 0
    set r1, 1
    sub r0
    set r1, 0
    add i

FOR_LOOP_START:
    # i++ # i become 0 when first run
    mov r0, i
    set r1, 1
    add i

    # int shift = 15 - i;
    set r0, FIFTEEN
    mov r1, i
    sub temp3 # shift

    # shift = divident_temp >> shift;
    	mov r0, divident_temp_LSW
 	mov r1, temp3
 	srl r2
 	set r0, 8
 	sub r1
 	mov r0, divident_temp_MSW
 	sll r1
 	mov r0, r2
 	or r2
 	mov r0, divident_temp_MSW
 	mov r1, temp3
 	sra r0



    # shift = shift & 1;
    mov r1, r2
    set r0, 1
    and temp3

    # int div = div << 1;
    set r0, 1
    set r1, 0
    add temp
    	mov r0, div_MSW
 	mov r1, temp
 	sll r2
 	set r0, 8
 	sub r1
 	mov r0, div_LSW
 	srl r1
 	mov r0, r2
 	or div_MSW
 	mov r0, div_LSW
 	mov r1, temp
 	sll div_LSW




    # div = div + shift;
    mov r0, temp3
    mov r1, div_LSW
    add div_LSW
    set r0, 0
    mov r1, div_MSW
    adc div_MSW

    # quotient = (quotient << 1);
    set r0, 1
    set r1, 0
    add r3
    	mov r0, quotient_MSW
 	mov r1, r3
 	sll r2
 	set r0, 8
 	sub r1
 	mov r0, quotient_LSW
 	srl r1
 	mov r0, r2
 	or quotient_MSW
 	mov r0, quotient_LSW
 	mov r1, r3
 	sll quotient_LSW




    # if(div >= divisor_temp){  // check div < divisor_temp
    # compare upper MSB with 0, if MSB < 0, then it's negative
    
    mov r0, div_MSW
    set r1, 0
    blts CHECK_I
    # if MSB is same，means both 0, compare LSB, if LSB < divisor_temp
    mov r0, div_LSW
    mov r1, divisor_temp
    blts CHECK_I # if we didn't branch, then div >= divisor_temp
    # div = div - divisor_temp;
    # first: extend bit for divisor_temp
    set r0, 0
    set r1, 0
    add temp2 # temp2 holds MSB for extend_divisor_temp
              # remember, divisor_temp is just divisor which is positive
              # thus, temp2 is always 0

    # negate temp2, and divisor_temp into temp2(MSB), temp3(LSB)
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
    # finally, div = div + (- divisor_temp); = div + (temp2, temp3)
    mov r0, div_LSW
    mov r1, temp3 
    add div_LSW
    mov r1, div_MSW
    mov r0, temp2
    adc div_MSW
    # quotient = quotient + 1;
    mov r0, quotient_LSW
    set r1, 1
    add quotient_LSW
    mov r0, quotient_MSW
    set r1, 0
    adc quotient_MSW

CHECK_I:
    # time to check i
    set r0, FIFTEEN
    mov r1, i
    bne FOR_LOOP_START
    # end of for loop  

IF_EXIT:
    # store back into 126(MSW), 127(LSW)
    mov r0, quotient_MSW
    mov r1, quotient_LSW
    sw r0, QUOTIENT_RETURN_ADDR_MSW
    sw r1, QUOTIENT_RETURN_ADDR_LSW

    halt r0
