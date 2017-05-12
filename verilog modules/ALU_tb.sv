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


        ctrl_input = ADD;
        test_case++;
        a = 11;
        b = 23;
        assert ((out == 34) && (cout == 0) && (zero == 0));
        #10ns;

        test_case++;
        a = 127;
        b = 1;
        assert ((out == 0) && (cout == 1) && (zero == 1));
        #10ns;

        test_case++;
        a = 126;
        b = 1;
        assert ((out == 127) && (cout == 0) && (zero == 0));
        #10ns;


        ctrl_input = ADDC;
        test_case++;
        a = 11;
        b = 23;
        assert ((out == 35) && (cout == 0) && (zero == 0));
        #10ns;

        test_case++;
        a = 126;
        b = 1;
        assert ((out == 128) && (cout == 1) && (zero == 0));
        #10ns;

        test_case++;
        a = 254;
        b = 1;
        assert ((out == 0) && (cout == 1) && (zero == 1));
        #10ns;


        ctrl_input = SUB;
        test_case++;
        a = 126;
        b = 1;
        assert ((out == 125) && (cout == 0) && (zero == 0));
        #10ns;

        test_case++;
        a = 0;
        b = 1;
        assert ((out == 127) && (cout == 0) && (zero == 0));
        #10ns;

        test_case++;
        a = 1;
        b = 1;
        assert ((out == 9) && (cout == 0) && (zero == 1));
        #10ns;


        ctrl_input = SLL;
        test_case++;
        a = 8;
        b = 2;
        assert ((out == 32) && (cout == 0) && (zero == 0));
        #10ns;

        test_case++;
        a = 128;
        b = 1;
        assert ((out == 0) && (cout == 0) && (zero == 1));
        #10ns;

        test_case++;
        a = 255;
        b = 1;
        assert ((out == 254) && (cout == 0) && (zero == 0));
        #10ns;


        ctrl_input = SRA;
        test_case++;
        a = 1;
        b = 0;
        assert ((out == 1) && (cout == 0) && (zero == 0));
        #10ns;

        test_case++;
        a = 1;
        b = 1;
        assert ((out == 0) && (cout == 0) && (zero == 1));
        #10ns;

        test_case++;
        a = 'b11111111;
        b = 1;
        assert ((out == 'b11111111) && (cout == 0) && (zero == 0));
        #10ns;

        test_case++;
        a = 'b1000000;
        b = 1;
        assert ((out == 'b11000000) && (cout == 0) && (zero == 0));
        #10ns;


        ctrl_input = OR;
        test_case++;
        a = 'b01010101;
        b = 'b10101010;
        assert ((out == 'b11111111) && (cout == 0) && (zero == 0));
        #10ns;


        ctrl_input = NEG;
        test_case++;
        a = 'b01010101;
        b = 'b11110000;
        assert ((out == 'b10101010) && (cout == 0) && (zero == 0));
        #10ns;


        ctrl_input = AND;
        test_case++;
        a = 'b01010101;
        b = 'b10101010;
        assert ((out == 0) && (cout == 0) && (zero == 1));
        #10ns;


        $stop;
    end
endmodule

