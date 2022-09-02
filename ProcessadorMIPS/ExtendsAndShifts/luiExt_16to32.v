module luiExt_16to32(
    input [15:0] IN,
    output [31:0] OUT
);
    // zextend to lui instruction
    assign OUT = {IN, {16{1'b0}}};

endmodule