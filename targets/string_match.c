int bytes_match(char *string, int length, char pattern) {
    if (length == 0) {
        return 0;
    }

    int count = 0;

    char slice = string[0] >> 5;
    int total_bits = length * 8;
    for (int i = 3; i < total_bits; i++) {
        char byte = string[i / 8];
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


int main()
{
    char string[] = { 0b01001010, 0b10010100, 0b00010001, 0b01010000 };
    char pattern = 0b0101;
    int count = bytes_match(string, sizeof(string), pattern);
    printf("bytes_match: %d, should_be: %d\n", count, 5);
    return 0;
}
