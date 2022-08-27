module ByteSel_mux (
    input wire control,

    input wire [15:0] in_0, // input MSB
    input wire [15:0] in_1, // input LSB
    
    output wire [15:0] out
);
    assign out = (control) ? in_1 : in_0;
endmodule