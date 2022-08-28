module SignExt_16to32(
    input [15:0] IN,
    output [31:0] OUT
);
    // sign extend from 16 to 32 bits
    assign OUT = {{16{IN[15]}}, IN};

endmodule