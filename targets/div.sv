r0 : dividend
r1 : divisor
r2 : quotient
r3 : div
r4 : divident_neg
r5 : divisor_neg
r6 : divident_temp
r7 : divisor_temp
r8 : temp
r10: temp2
r9 : i 

start:
    //quotient = 0; //16 bit
    addi quotient, $zero, $zero 
    //if(divisor != 0){ //8 bit 0
    beq divisor, $zero, if_exit: 
    // div = 0;
    addi div, $zero, $zero 
    //temp = dividend >> 15
    lsr temp, dividend, 0x0f
    // first if start here
    // if(temp == 1)
    bne temp, 1, first_else
    //divident_neg = 1
    addi divident_neg $zero, 1
    //divisor_temp = ~dividend + 1;
    not temp dividend
    add divisor_temp temp 1
first_else
    addi divident_neg $zero, $zero; //1 bit
    addi divident_temp dividend $zero
    // second if start here
    // if(divisor >> 7 == 1){
    lsr temp, divisor, 0x07
    bne temp, 1, second_else
    //divisor_neg = 1; // 1 bit
    addi divisor_neg $zero 1
    //divisor_temp = ~divisor + 1;
    not temp divisor
    addi divisor_temp temp 1
second_else
    addi divisor_neg $zero $zero
    addi divisor_temp divisor $zero
    // int i = 0
    addi i, $zero, $zero
for_entry
    bne i 0x10 for_end
    //int shift = 15 - i;
    sub temp  0x0f i;
    srl temp divident_temp temp 
    and temp temp 1
    //int f = div << 1;
    srl temp2 div 1;
    add div temp2 temp1
    // if(div >= divisor_temp){
    blt div divisor_temp third_else
    sub div div divisor_temp
    srl temp quotient 1
    add quotient quotient 1
third_else
    srl temp quotient 1
    add quotient temp 0
    //if(divident_neg != divisor_neg){
    beq divident_neg divisor_neg last
    not quotient quotient
    add quotient quotient 1
last
    
    //i++
    addi i, i, 1
    bne i 0x10 for_entry

for_end
if_exit