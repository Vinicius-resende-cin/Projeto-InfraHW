module RegDst_mux (
    input wire [1:0] control
    
    input wire[31:0] in_0, // instrução (rt) - 00
    input wire[31:0] in_1, // instrução (rd) - 01

    
    output wire[31:0] out
);

assign out = (control[1]? (control[0] ? 32'd31 : 32'd29) : (control[0] ? in_1 : in_0));
    
endmodule
