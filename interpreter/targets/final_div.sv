# dividend 1000 // 16 bit at memory  128, 129
# divisor 3; //8 bit at memory 130
# r6 = i
# r7 = divident_temp 0; 
# r8 = divident_temp 1;
# r9 = divisor
# r10 = quotient 0;
# r11 = div 0;
# r12 = divident_neg 0;
# r13 = divisor_neg 0;
# r14 = divisor_temp 0;
# r15 = $ZERO

#Look Up Table (0-31)
# Entry --  Address
# 0     --  128   -- DIVIDEND_ADDR_0
# 1     --  129   -- DIVIDEND_ADDR_1
# 2     --  130   --  DIVISOR_ADDR
DIVISOR_ADDR = 2

#Branch Table(0-31)
# Entry -- Address
# 0     -- IF_EXIT
# 1     -- FIRST_ELSE
IF_EXIT = 0

start:
    # quotient = 0;
    set 0 # r0 = 0
    mov r0 r1 # set r0 and r1 to 0
    add r0 quotient(r10) 

    #if(divisor != 0){
    lw DIVISOR_ADDR # mem[128] store into r0
    mv divisor(r1) r0 # divisor store into r1 
    set 0 # r0 = 0, r1 = divisor
    add r9 # store divisor in r9
    beq IF_EXIT # compare r0 r1 and branch 

    # div = 0;
    set 0
    mov r1 r15 # set both to 0
    add r11 # r11 is div

#first if
    #if(dividend >> 15 == 1){ 
    set 7 # r0 is 7
    mv r1 r0 # save 7 into r1
    lw 0 # we are shift 15, thus we need to shift 7 time on MSB
    srl r1 # save the result into r1
    set 1 # r0(1)
    bne FIRST_ELSE # cmp r0(1) r1(shift result) 

    # divident_neg = 1; 
    set 1 # r0 = 1
    mov r1 r15 # set both to 0
    add r12(divident_neg)
    #divident_temp = ~dividend + 1;
    lw DIVIDEND_ADDR_1
    neg r1
    set 1 # r0 =1, r1 = -LSB
    add r8
    lw DIVIDEND_ADDR_0
    neg r1
    adc r7
FIRST_ELSE:
    # divident_neg = 0; 
    set 0 # r0 = 1
    mov r1 r15 # set both to 0
    add r12(divident_neg)
    # divident_temp = dividend;
    lw DIVIDEND_ADDR_1
    mov r1 r15 # set r1 to 0
    add r8
    lw DIVIDEND_ADDR_0
    mov r1 r15 # set r1 to 0
    add r7

# second if
    # if(divisor >> 7 == 1){
    set 7 # r0 is 7

    mv r1 r0 # save 7 into r1
    lw 2 # load my divsior 
    srl r1 #save the result into r1
    set 1 # r0(1)
    bne SECOND_ELSE # cmp r0(1) r1(shift result) 

    # divisor_neg = 1;
    set 1 # r0 = 1
    mov r1 r15 # set both to 0
    add r13(divisor_neg)
    # divisor_temp = ~divisor + 1;
    lw DIVISOR_ADDR
    neg r1
    set 1
    add r14(divisor_temp) # save 
SECOND_ELSE:
    # divisor_neg = 0;
    set 0 # r0 = 1
    mov r1 r15 # set both to 0
    add r13(divisor_neg)
    # divisor_temp = divisor;
    lw DIVISOR_ADDR
    mov r1 r15 # set r1 to 0
    add r14(divisor_temp) # save 

    # int i = 0;
    set 0
    mov r1 r15 # set both to 0
    add r6(i)

FOR_START:
    # get i
    mov r1 r6
    set 16
    beq FOR_END

    #int shift = 15 - i;
    set 15
    sub r1 # shift in r1
    # int b = (divident_temp >> shift) & 1;

    # say b is in r2

    # int f = div << 1;
    set 1
    mov r1 r0
    mov r0 r11 
    sll r1

    # div = f + b;
    mov r0 r2 
    add r1 # save div temperary to t1

    mov r0 r14
    #TODO ERASE
    mv r0 14
    mv r0 41
    slt r1
    mv r2 r0
    sub r2
    mv r1 0
    mv r14 r0
    sll r1

    #TODO i++
FOR_END:


IF_EXIT:
    # save result back to TODO
    mv r0 r7
    sw 3
    mv r1 r0
    sw 4
