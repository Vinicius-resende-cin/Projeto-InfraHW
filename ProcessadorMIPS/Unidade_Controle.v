module Unidade_Controle (
    input [5:0] opcode, funct,
    output RESET, BREAK, PCwrite, MemRead, MemWrite, IRwrite, RegWrite, MultOp, DivOp, EPCwrite, // 1 bit action signals
    output IorD, BHsel, RegSrc, ALUsrcA, ShamtSrc, ShiftData, ALUtoReg, MorDHI, MorDLO, // 1 bit MUX signals
    output [1:0] MemData, RedDst, ALUsrcB, // 2 bit MUX signals
    output [2:0] ALUop, ShiftOp, // 3 bit action signals
    output [2:0] PCsrc, // 3 bit MUX signals
    output [3:0] RegData // 4 bit MUX signal
);
    
endmodule