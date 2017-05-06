#include <stdio.h>

int bytes_match(unsigned char *string, int length, char pattern) {
    int count = 0;

    char slice = string[0] >> 5;
    int total_bits = length * 8;
    for (int i = 3; i < total_bits; i++) {
        unsigned char byte = string[i / 8];
        char bit = (byte >> (7 - i % 8)) & 1;
        slice = ((slice << 1) & 0b1111) | bit;
        if (slice == pattern) {
            if (count < 255) {
                count++;
            }
        }
    }

    return count;
}

int bytes_match_2(unsigned char *string, int length, char pattern) {
    int count = 0;

    char slice = string[0] >> 5;
    int j = 4;
    for (int i = 0; i < length; i++) {
        unsigned char byte = string[i];
        for (; j >= 0; j--) {
            char bit = (byte >> j) & 1;
            slice = ((slice << 1) & 0b1111) | bit;
            if (slice == pattern) {
                count++;
            }
            if (count == 255) {
                break;
            }
        }
        j = 7;
    }

    return count;
}


int main()
{
    unsigned char string[] = { 0b01001010, 0b10010100, 0b00010001, 0b01010000 };
    char pattern = 0b0101;
    int count = bytes_match(string, sizeof(string), pattern);
    int count_2 = bytes_match(string, sizeof(string), pattern);
    printf("bytes_match: %d, should_be: %d\n", count_2, count);
    return 0;
}
