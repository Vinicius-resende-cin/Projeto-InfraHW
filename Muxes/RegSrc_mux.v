module RegSrc_mux (
    input wire control,

    input wire[31:0] in_0, // sp - 0
    input wire[31:0] in_1, // instrução (rs) - 1

    output wire[31:0] out
);

    assign out = control ? in_1 : in_0;
endmodule
