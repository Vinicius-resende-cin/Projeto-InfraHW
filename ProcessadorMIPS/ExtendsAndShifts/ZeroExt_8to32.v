module ZeroExt_8to32(
    input [7:0] IN,
    output [31:0] OUT
);
    // zero extend from 8 to 32 bits
    assign OUT = {{24{1'b0}}, IN};

endmodule