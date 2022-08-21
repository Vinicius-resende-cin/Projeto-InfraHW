module RegDst_mux (
    input wire [1:0] control
    
    input wire[31:0] in_0, // instrução (rt) - 00
    input wire[31:0] in_1, // instrução (rd) - 01
    input wire[31:0] in_2, // sp - 10
    input wire[31:0] in_3, // ra - 11
    
    output wire[31:0] out
);

assign out = (control[1]? (control[0] ? in_3 : in_2) : (control[0] ? in_1 : in_0));
    
endmodule
