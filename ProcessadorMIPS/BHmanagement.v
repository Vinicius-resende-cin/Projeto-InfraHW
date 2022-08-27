`include "ExtendsAndShifts/SignExt_16to32.v"
`include "ExtendsAndShifts/SignExt_8to32.v"
`include "ExtendsAndShifts/ZeroExt_8to32.v"

module BHmanagement(
    input [31:0] MemData,
    output [15:0] MemDataMSB, MemDataLSB,
    output [31:0] Half32, Byte32, Byte32U
);
    assign MemDataMSB = MemData[31:16];
    assign MemDataLSB = MemData[15:0];

    SignExt_16to32 halfsel(MemData[15:0], Half32);
    SignExt_8to32 bytesel(MemData[7:0], Byte32);
    ZeroExt_8to32 byteselU(MemData[7:0], Byte32U);

endmodule