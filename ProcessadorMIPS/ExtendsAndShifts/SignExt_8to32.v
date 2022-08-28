module SignExt_8to32(
    input [7:0] IN,
    output [31:0] OUT
);
    // sign extend from 8 to 32 bits
    assign OUT = {{24{IN[7]}}, IN};

endmodule