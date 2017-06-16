/* Hello World program */
#include<stdio.h>

int main()
{
    signed int dividend = 23130; //16 bit (signed)
    signed int divisor = 120;  //8 bit (signed)
    signed int quotient = 0; //16 bit (signed)
    int div = 0; //16 bit
    int divident_temp = 0; //16 bit
    int divisor_temp = 0; //8 bit


    quotient = 0; //16 bit

    if(divisor != 0){ //8 bit 0
        div = 0; //16 bit
    
        divident_temp = dividend;
        divisor_temp = divisor;
       
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
            quotient = (quotient << 1);
            
            // third if
            printf("lala %d\n", i);
            if(div >= divisor_temp){
                printf("Hereererererere\n");
                div = div - divisor_temp;
                quotient = quotient + 1; // 1 is 1 bit
            }
            printf("%d\n", quotient);
            
        }
    }
    printf("Hello World: %d", quotient);
}