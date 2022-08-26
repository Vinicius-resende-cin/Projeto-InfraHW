module RegSrc_mux (
    input wire control,

    input wire[4:0] in_1, // instrução (rs) - 1

    output wire[4:0] out
);

    assign out = control ? in_1 : 5'd29;
endmodule
