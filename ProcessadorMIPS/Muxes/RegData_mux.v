module RegData_mux (
    input wire[3:0] control,
                             // 227 - 0000
    input wire[31:0] in_1, // MemData - 0001
    input wire[31:0] in_2, // ALUOut - 0010
    input wire[31:0] in_3, // HI - 0011
    input wire[31:0] in_4, // LO - 0100
    input wire[31:0] in_5, // ShiftRegister - 0101
    input wire[31:0] in_6, // Half - 0110
    input wire[31:0] in_7, // Byte - 0111
    input wire[31:0] in_8, // Immediate - 1000

    output wire [31:0] out;
);

assign out = control[3] ? in_8 : (control[2]? (control[1]? (control[0]? in_7 : in_6) : (control[0]? in_5 : in_4)) : (control[1] ? (control[0] ? in_3 : in_2) : control[0] ? in_1 : 32'b00000000000000000000000011100011));
    
endmodule
