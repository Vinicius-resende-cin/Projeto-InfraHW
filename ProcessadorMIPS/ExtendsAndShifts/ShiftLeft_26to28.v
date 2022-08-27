module ShiftLeft_26to28(
    input [25:0] IN,
    output [27:0] OUT
);
    // shift left 2 and extend from 26 to 28 bits
    assign OUT = {IN, {2{1'b0}}};

endmodule