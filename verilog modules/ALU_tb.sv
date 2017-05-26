import ALU_def::*;
module ALU_tb;
    bit [10:0] test_case;

    // Input
    bit cin;
    ALU_CTRL ctrl_input;
    bit [7:0] a, b;

    // Output
    bit [7:0] out;
    bit cout;
    bit zero;

    // Instantiate the Unit Under Test (UUT)
    ALU uut(
        .cin,
        .ctrl_input,
        .a,
        .b,
        .out,
        .cout,
        .zero
    );

    initial begin
        // Wait 100 ns for global reset to finish
        #100ns;
        test_case = 0;
        cin = 1;


        ctrl_input = ALU_ADD;
        test_case++;
        a = 11;
        b = 23;
        #10ns;
        assert ((out == 34) && (cout == 0) && (zero == 0));
        #10ns;

        test_case++;
        a = 127;
        b = 1;
        #10ns;
        assert ((out == 128) && (cout == 0) && (zero == 0));
        #10ns;

        test_case++;
        a = 255;
        b = 1;
        #10ns;
        assert ((out == 0) && (cout == 1) && (zero == 1));
        #10ns;

        test_case++;
        a = 254;
        b = 1;
        #10ns;
        assert ((out == 255) && (cout == 0) && (zero == 0));
        #10ns;


        ctrl_input = ALU_ADDC;
        test_case++;
        a = 11;
        b = 23;
        #10ns;
        assert ((out == 35) && (cout == 0) && (zero == 0));
        #10ns;

        test_case++;
        a = 126;
        b = 1;
        #10ns;
        assert ((out == 128) && (cout == 0) && (zero == 0));
        #10ns;

        test_case++;
        a = 254;
        b = 1;
        #10ns;
        assert ((out == 0) && (cout == 1) && (zero == 1));
        #10ns;

        test_case++;
        a = 253;
        b = 1;
        #10ns;
        assert ((out == 255) && (cout == 0) && (zero == 0));
        #10ns;


        ctrl_input = ALU_SUB;
        test_case++;
        a = 126;
        b = 1;
        #10ns;
        assert ((out == 125) && (cout == 0) && (zero == 0));
        #10ns;

        test_case++;
        a = 0;
        b = 1;
        #10ns;
        assert ((out == 255) && (cout == 0) && (zero == 0));
        #10ns;

        test_case++;
        a = 1;
        b = 1;
        #10ns;
        assert ((out == 0) && (cout == 0) && (zero == 1));
        #10ns;


        ctrl_input = ALU_SLL;
        test_case++;
        a = 8;
        b = 2;
        #10ns;
        assert ((out == 32) && (cout == 0) && (zero == 0));
        #10ns;

        test_case++;
        a = 128;
        b = 1;
        #10ns;
        assert ((out == 0) && (cout == 0) && (zero == 1));
        #10ns;

        test_case++;
        a = 255;
        b = 1;
        #10ns;
        assert ((out == 254) && (cout == 0) && (zero == 0));
        #10ns;


        ctrl_input = ALU_SRA;
        test_case++;
        a = 1;
        b = 0;
        #10ns;
        assert ((out == 1) && (cout == 0) && (zero == 0));
        #10ns;

        test_case++;
        a = 1;
        b = 1;
        #10ns;
        assert ((out == 0) && (cout == 0) && (zero == 1));
        #10ns;

        test_case++;
        a = 'b11111111;
        b = 1;
        #10ns;
        assert ((out == 'b11111111) && (cout == 0) && (zero == 0));
        #10ns;

        test_case++;
        a = 'b1000000;
        b = 1;
        #10ns;
        assert ((out == 'b100000) && (cout == 0) && (zero == 0));
        #10ns;

        test_case++;
        a = 'b10000000;
        b = 1;
        #10ns;
        assert ((out == 'b11000000) && (cout == 0) && (zero == 0));
        #10ns;

        test_case++;
        a = 'b11111111;
        b = -1;
        #10ns;
        assert ((out == 'b11111110) && (cout == 0) && (zero == 0));
        #10ns;


        ctrl_input = ALU_SRL;
        test_case++;
        a = 'b100;
        b = 1;
        #10ns;
        assert ((out == 'b10) && (cout == 0) && (zero == 0));
        #10ns;

        test_case++;
        a = 'b10000000;
        b = 1;
        #10ns;
        assert ((out == 'b1000000) && (cout == 0) && (zero == 0));
        #10ns;

        test_case++;
        a = 'b1;
        b = -2;
        #10ns;
        assert ((out == 'b100) && (cout == 0) && (zero == 0));
        #10ns;

        test_case++;
        a = 'b10000000;
        b = -1;
        #10ns;
        assert ((out == 0) && (cout == 0) && (zero == 1));
        #10ns;


        ctrl_input = ALU_SLL;
        test_case++;
        a = 'b101;
        b = 3;
        #10ns;
        assert ((out == 'b101000) && (cout == 0) && (zero == 0));
        #10ns;

        test_case++;
        a = 'b101;
        b = -1;
        #10ns;
        assert ((out == 'b10) && (cout == 0) && (zero == 0));
        #10ns;


        ctrl_input = ALU_LT;
        test_case++;
        a = 10;
        b = 10;
        #10ns;
        assert ((out == 0) && (cout == 0) && (zero == 1));
        #10ns;

        test_case++;
        a = 10;
        b = 11;
        #10ns;
        assert ((out == 1) && (cout == 0) && (zero == 0));
        #10ns;

        test_case++;
        a = 255;
        b = 0;
        #10ns;
        assert ((out == 0) && (cout == 0) && (zero == 1));
        #10ns;


        ctrl_input = ALU_LTS;
        test_case++;
        a = 10;
        b = 10;
        #10ns;
        assert ((out == 0) && (cout == 0) && (zero == 1));
        #10ns;

        test_case++;
        a = 10;
        b = 11;
        #10ns;
        assert ((out == 1) && (cout == 0) && (zero == 0));
        #10ns;

        test_case++;
        a = 255;
        b = 0;
        #10ns;
        assert ((out == 1) && (cout == 0) && (zero == 0));
        #10ns;

        test_case++;
        a = 128;
        b = 0;
        #10ns;
        assert ((out == 1) && (cout == 0) && (zero == 0));
        #10ns;

        test_case++;
        a = -17;
        b = -17;
        #10ns;
        assert ((out == 0) && (cout == 0) && (zero == 1));
        #10ns;

        test_case++;
        a = -18;
        b = -17;
        #10ns;
        assert ((out == 1) && (cout == 0) && (zero == 0));
        #10ns;

        test_case++;
        a = -16;
        b = -17;
        #10ns;
        assert ((out == 0) && (cout == 0) && (zero == 1));
        #10ns;


        ctrl_input = ALU_OR;
        test_case++;
        a = 'b01010101;
        b = 'b10101010;
        #10ns;
        assert ((out == 'b11111111) && (cout == 0) && (zero == 0));
        #10ns;


        ctrl_input = ALU_NEG;
        test_case++;
        a = 'b01010101;
        b = 'b11110000;
        #10ns;
        assert ((out == 'b10101010) && (cout == 0) && (zero == 0));
        #10ns;


        ctrl_input = ALU_AND;
        test_case++;
        a = 'b01010101;
        b = 'b10101010;
        #10ns;
        assert ((out == 0) && (cout == 0) && (zero == 1));
        #10ns;


        $stop;
    end
endmodule

