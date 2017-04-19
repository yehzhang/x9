int bytes_match(uint8_t *string, size_t length, uint8_t pattern) {
    if (pattern > 0b1111) {
        printf("Pattern is too large.\n");
        return -1;
    }
    if (length == 0 || string == 0) {
        return 0;
    }

    int count = 0;

    uint8_t slice = string[0] >> 5;
    int total_bits = length * 8;
    for (int i = 3; i < total_bits; i++) {
        uint8_t byte = string[i / 8];
        uint8_t bit = (byte >> (7 - i % 8)) & 1;
        slice = ((slice << 1) & 0b1111) | bit;
        // printf("byte: 0x%02x, bit: %d, slice: 0x%02x, hit: %d\n", byte, bit, slice, slice == pattern);
        if (slice == pattern) {
            if (slice < 255) {
                count++;
            }
        }
    }

    return count;
}


int main()
{
    uint8_t string[] = { 0b01001010, 0b10010100, 0b00010001, 0b01010000 };
    uint8_t pattern = 0b0101;
    int count = bytes_match(string, sizeof(string), pattern);
    printf("bytes_match: %d, should_be: %d\n", count, 5);
    return 0;
}

# bytes_match:
    set 0

    add r0, ac

