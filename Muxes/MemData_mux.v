module MemData_mux (
    input wire [1:0] control,

    input wire [31:0] in_0, // RegB (rt) - 00
    input wire [31:0] in_1, // Half - 01
    input wire [31:0] in_2, // Byte - 10

    output wire [31:0] out
);
    assign out = (control[1] ? in_2 : (control[0] ? in_1 : in_0));
endmodule
