`include "Muxes/ALUSrcA_mux.v"
`include "Muxes/ALUSrcB_mux.v"
`include "Muxes/IorD_mux.v"
`include "Muxes/RegSrc_mux.v"
`include "Muxes/RegDst_mux.v"
`include "Muxes/RegData_mux.v"
`include "Muxes/AluToReg_mux.v"
`include "Muxes/PCSource_mux.v"
`include "Muxes/MemData_mux.v"
`include "Muxes/ShamtSrc_mux.v"
`include "Muxes/ShiftData_mux.v"
`include "ltExt_1to32.v"
`include "luiExt_16to32.v"
`include "ShiftLeft_26to28.v"
`include "ShiftLeft2.v"
`include "SignExt_8to32"
`include "SignExt_16to32"
`include "ZeroExt_8to32"
`include "Unidade_Controle.v"
`include "BHmanagement.v"

module CPU (
    input wire clk,
    input wire reset_in
);

wire reset;

wire PC_write;
wire [31:0] PC_in;
wire [31:0] PC_out;

wire Iord_control;
wire [31:0] Iord_out;
wire [2:0] ALU_op;
wire [31:0] ALU_result;
wire ALU_of;
wire ALU_neg;
wire ALU_z;
wire ALU_eq;
wire ALU_gt;
wire ALU_lt;

wire ALUout_write;
wire [31:0] Alu_Out;

wire Mem_write;
wire [31:0] Data_in;
wire [31:0] Data_out;

wire Load_ir;
wire [5:0] Instr31_26;
wire [4:0] Instr25_21;
wire [4:0] Instr20_16;
wire [15:0] Instr15_0;

wire RegSrc_control;
wire [4:0] RegSrc_out;

wire [1:0] RegDst_control;
wire [4:0] RegDst_out;

wire [3:0] RegData_control;
wire [31:0] MemData_out;
wire [31:0] HI;
wire [31:0] LO ;
wire [31:0] ShiftReg_out ;
wire [31:0] Immediate;
wire [31:0] RegData_out;

wire Reg_write;
wire [31:0] ReadData_1;
wire [31:0] ReadData_2;

wire RegA_write;
wire [31:0] RegA_out;

wire RegB_write;
wire [31:0] RegB_out;

wire ALUSrcA_control;
wire [31:0] ALUSrcA_out;

wire [1:0] ALUSrcB_control;
wire [31:0] SignExt;
wire [31:0] ShiftLeft_2;
wire [31:0] ALUSrcB_out;

wire AluToReg_control;
wire [31:0] Flag;
wire [31:0] AluToReg_out;

wire [2:0] PCSource_control;
wire [31:0] InstrunctionToPCSource;
wire [27:0] Instr250_sl; // Igor vai mandar o shift left depois
assign InstrunctionToPCSource = {PC_out[31:28], Instr250_sl};
wire [31:0] EPC_out;
wire [31:0] PCSource_out;


wire[31:0] ShiftData_out;
wire[4:0] ShamtSrc_out;

wire[2:0] Shift_op;

wire[31:0] ShiftRegistor_out;

wire [15:0] MemDataMSB;
wire [15:0] MemDataLSB;
wire [31:0] Half32;
wire [31:0] Byte32;
wire [31:0] Byte32U;

wire [31:0] temp;


Registrador PC(clk, reset, PC_write, PC_in, PC_out);
IorD_mux Iord(Iord_control, PC_out, Alu_Out, Iord_out);
Memoria Mem(Iord_out, clk, Mem_write, Data_in, Data_out);
Instr_Reg Inst_reg(clk, reset, Load_ir, Data_out, Instr31_26, Instr25_21, Instr20_16, Instr15_0);
RegSrc_mux RedSrc(RegSrc_control, Instr25_21, RegSrc_out);
RegDst_mux RegDst(RegDst_control, Instr20_16, Instr15_0[15:11], RegDst_out);
RegData_mux RegData(RegData_control, MemData_out, Alu_Out, HI, LO, ShiftReg_out, Half32, Byte32, Immediate, RegData_out);
Banco_reg Reg_bank(clk, reset, Reg_write, RegSrc_out, Instr20_16, RegDst_out, RegData_out, ReadData_1, ReadData_2);
Registrador A(clk, reset, RegA_write, ReadData_1, RegA_out);
Registrador B(clk, reset, RegB_write, ReadData_2, RegB_out);
ALUSrcA_mux ALUSrcA(ALUSrcA_control, PC_out, RegA_out, ALUSrcA_out);
ALUSrcB_mux ALUSrcB(ALUSrcB_control, RegB_out, SignExt, ShiftLeft_2, ALUSrcB_out);
ula32 ALU(ALUSrcA_out, ALUSrcB_out, ALU_op, ALU_result, ALU_of, ALU_neg, ALU_z, ALU_eq, ALU_gt, ALU_lt);
AluToReg_mux AluToReg(AluToReg_control, ALU_result, Flag, AluToReg_out);
Registrador ALUout(clk, reset, ALUout_write, AluToReg_out, Alu_Out);
PCSource_mux PCSource(PCSource_control, ALU_result, Alu_Out, InstrunctionToPCSource, EPC_out, Byte32U, PCSource_out);

Registrador RegMemData(clk, reset, MemData_write, Data_out, MemData_out);
ShiftData_mux ShiftData(ShiftData_control, RegA_out, RegB_out, ShiftData_out);
ShamtSrc_mux ShamtSrc(ShamtSrc_control, Instr15_0, RegB_out[4:0], ShamtSrc_out);
RegDesloc ShiftReg(clk, reset, Shift_op, ShamtSrc_out, ShiftData_out, ShiftReg_out);
Registrador EPC(clk, reset, EPC_write, ALU_result, EPC_out);
SignExt_16to32 signExt_16to32(Instr15_0, SignExt);
ShiftLeft2 shiftLeft2(SignExt, ShiftLeft_2);
luiExt_16to32 Lui(Instr15_0, Immediate);
BHmanagement bhManagement(MemData_out, MemDataMSB, MemDataLSB, Half32, Byte32, Byte32U);
MemData_mux MemData(MemData_control, RegB_out, {MemDataMSB, RegB_out[15:0]}, {MemDataMSB, MemDataLSB[15:8], RegB_out[7:0]});
ShiftLeft_26to28 shiftLeft_26to28({Instr25_21, Instr20_16, Instr15_0}, Instr250_sl);
ltExt_1to32 lt_ext_1to32(ALU_lt, Flag);

Unidade_Controle UnidadeControle(clk, reset_in, Instr31_26, Instr15_0[5:0], ALU_gt, ALU_lt, ALU_eq, ALU_of, ALU_neg, ALU_z,
 temp, reset, temp, PC_write, Mem_write, Load_ir, Reg_write, temp, temp, EPC_write, ALUout_write, RegA_write, RegB_write, temp, temp, 
 MemData_write, Iord_control, RegSrc_control, ALUSrcA_control, ShamtSrc_control, ShiftData_control, AluToReg_control, temp, 
 temp, MemData_control, RegDst_control, ALUSrcB_control, ALU_op, Shift_op, PCSource_control, RegData_control);

endmodule