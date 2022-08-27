module ShiftLeft2(
    input [31:0] IN,
    output [31:0] OUT
);
    // shift left 2
    assign OUT = {IN[29:0], {2{1'b0}}};

endmodule