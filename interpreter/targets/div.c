/* Hello World program */

#include<stdio.h>

int main()
{
    int dividend = 1000;
    int divisor = 3;
    int quotient = 0;
    int div = 0;
    int divident_neg = 0;
    int divisor_neg = 0;
    int divident_temp = 0;
    int divisor_temp = 0;

    quotient = 0; //16 bit
    if(divisor != 0){ //8 bit 0
        div = 0;

        // first if
        if(dividend >> 15 == 1){  //if most sig bit is 1
            divident_neg = 1; //1 bit
            divisor_temp = ~dividend + 1; //
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
        int i = 0;
        for(i = 0; i < 16; i++){
            //get the 15 - i  bit
            int shift = 15 - i;
            int b = (divident_temp >> shift) & 1;
            //get div[14:0]
            int f = div << 1;
            div = f + b;
            if(div >= divisor_temp){
                div = div - divisor_temp;
                quotient = (quotient << 1) + 1; // 1 is 1 bit
            }else{
                quotient = (quotient << 1) + 0; // 0 is 1 bit
            } 
        }
        if(divident_neg != divisor_neg){
            quotient = ~quotient + 1; //1 is 1 bit;
        }
    }
    printf("Hello World: %d", quotient);

}