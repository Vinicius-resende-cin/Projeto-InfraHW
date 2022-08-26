module ShamtSrc_mux (
    input wire control,
    input wire [4:0] in_0, // instrução (shamt) - 0
    input wire [4:0] in_1, // RegB[4:0] - 1

    output wire[4:0] out
);
    assign out = control ? in_1 : in_0;
endmodule
