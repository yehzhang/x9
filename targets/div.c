/* Hello World program */
#include<stdio.h>

int main()
{
    signed int dividend = 20; //16 bit (signed)
    signed int divisor = 3;  //8 bit (signed)
    signed int quotient = 0; //16 bit (signed)
    int div = 0; //16 bit
    int divident_neg = 0;
    int divisor_neg = 0;
    int divident_temp = 0; //16 bit
    int divisor_temp = 0; //8 bit

    quotient = 0; //16 bit
    if(divisor != 0){ //8 bit 0
        div = 0; //16 bit

        // first if
        if(dividend >> 15 == 1){  //if most sig bit is 1
            divident_neg = 1; //1 bit
            divident_temp = ~dividend + 1; //
        }else{
            divident_neg = 0; //1 bit
            divident_temp = dividend;
        }
        //second if
        if(divisor >> 7 == 1){
            divisor_neg = 1; // 1 bit
            divisor_temp = ~divisor + 1;
        }else{
            divisor_neg = 0; // 1 bit
            divisor_temp = divisor;
        }

        // for start
        int i = 0;
        for(i = 0; i < 16; i++){
            //get the 15 - i  bit
            int shift = 15 - i; //shift is 16 bit
            shift = divident_temp >> shift;
            shift = shift & 1;
            //get div[14:0]
            int div = div << 1;
            div = div + shift;

            // third if
            if(div >= divisor_temp){
                div = div - divisor_temp;
                quotient = (quotient << 1);
                quotient = quotient + 1; // 1 is 1 bit
            }else{
                quotient = (quotient << 1);
            } 
        }
        if(divident_neg != divisor_neg){
            quotient = ~quotient + 1; //1 is 1 bit;
        }
    }
    printf("Hello World: %d", quotient);
}