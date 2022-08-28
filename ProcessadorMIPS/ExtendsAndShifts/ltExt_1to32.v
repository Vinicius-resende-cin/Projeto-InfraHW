module ltExt_1to32(
    input IN,
    output [31:0] OUT
);
    // zero extend to the slt / slti instructions
    assign OUT = {{31{1'b0}}, IN};

endmodule