#include <stdio.h>
int main(){


    int dividend = 180; //16 bits, store in location 128, 129
    int divisor = 80; //8 bits, store in location 130

    int quotient = 0<<15;//16 bits
    int div;
    int dividend_neg;
    int dividend_temp;
    int divisor_neg;
    int divisor_temp;
    if(divisor != 0<<7){
        div = 0<<15;

        if((dividend>>15)==1){
            printf("neg divident\n");
            dividend_neg = 1;//1 bit 
            dividend_temp = ~dividend + 1;
        }
        else{
            dividend_neg = 0; //1 bit 
            dividend_temp = dividend;
        }
        if((divisor>>7) == 1){ //this is for 16 bits situation
            printf("neg divisor\n");
            divisor_neg = 1;//1 bit 
            divisor_temp = ~divisor + 1;
        }
        else{
            divisor_neg = 0;//1 bit 
            divisor_temp = divisor;
        }



        for(int i=0;i<16;i++){
            div = (div>>1<<1) +  (dividend_temp<<i>>15);
            // div = (div<<18>>17) +  ((dividend_temp>>(15-i))&1);
            if(div>=divisor_temp){
                div = div - divisor_temp;
                quotient = (quotient>>1<<1) + 1;
                // quotient = (quotient<<18>>17) + 1;
            }
            else{
                quotient = (quotient>>1<<1) + 0;
                // quotient = (quotient<<18>>17) + 0;
            }
        }

        if(dividend_neg != divisor_neg){
            quotient = ~quotient + 1;
        }
    }

    // printf("%d\n", quotient);
}