module ShiftData_mux (
    input wire control,
    input wire [31:0] in_0, // RegA - 0
    input wire [31:0] in_1, // RegB - 1

    output wire[31:0] out
);
    assign out = control ? in_1 : in_0;
endmodule
