module luiExt_16to32(
    input [15:0] IN,
    output [31:0] OUT
);
    // zero extend to lui instruction
    assign OUT = {{16{1'b0}}, IN};

endmodule