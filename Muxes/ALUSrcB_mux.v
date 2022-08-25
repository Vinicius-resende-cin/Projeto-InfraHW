module ALUSrcB_mux (
    input wire[1:0] control,
    
    input wire[31:0] in_0, // RegB - 00
                           // 4 - 01
    input wire[31:0] in_2, // sign extend (Immediate estendido) - 10
    input wire[31:0] in_3, // shift left 2 - 11

    output wire[31:0] out
);
    
    assign out = (control[1]? (control[0] ? in_3 : in_2) : (control[0] ? 32'b00000000000000000000000000000100 : in_0));
endmodule
