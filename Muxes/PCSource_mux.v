module PCSource_mux (
    input wire[2:0] control,

    input wire[31:0] in_0, // ALU - 000
    input wire[31:0] in_1, // ALUOut - 001
    input wire[31:0] in_2, // Instruction - 010
    input wire[31:0] in_3, // EPC - 011
    input wire[31:0] in_4, // Exception - 100
    input wire[31:0] in_5, // 253 - 101
    input wire[31:0] in_6, // 254 - 110
    input wire[31:0] in_7, // 255 - 111

    output wire [31:0] out
);
    assign out = (control[2] ? (control[1] ? (control[0] ? in_7 : in_6) : (control[0] ? in_5 : in_4)) : (control[1] ? (control[0] ? in_3 : in_2) : (control[0] ? in_1 : in_0)));
endmodule
