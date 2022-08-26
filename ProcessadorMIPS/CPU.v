`include "Memoria.vhd"
`include "Instr_Reg.vhd"
`include "Banco_reg.vhd"
`include "Registrador.vhd"
`include "ula32.vhd"
`include "Muxes/ALUSrcA_mux.v"
`include "Muxes/ALUSrcB_mux.v"
`include "Muxes/Iord_mux.v"
`include "Muxes/RegSrc_mux.v"
`include "Muxes/RegDst_mux.v"
`include "Muxes/RegData_mux.v"
`include "Muxes/AluToReg_mux.v"
`include "Muxes/PCSource_mux.v"
`include "Unidade_Controle.v"

module CPU (
    input wire clk,
    input wire reset_in
);

wire reset;

wire PC_write;
wire PC_in;
wire PC_out;

wire Iord_control;
wire Iord_out;

wire ALU_op;
wire ALU_result;
wire ALU_of;
wire ALU_neg;
wire ALU_z;
wire ALU_eq;
wire ALU_gt;
wire ALU_lt;

wire ALUout_write;
wire Alu_Out;

wire Mem_write;
wire Data_in ;
wire Data_out;

wire Load_ir;
wire Instr31_26;
wire Instr25_21;
wire Instr20_16;
wire Instr15_0;

wire RegSrc_control;
wire RegSrc_out;

wire RegDst_control;
wire RegDst_out;

wire RegData_control;
wire MemData;
wire HI;
wire LO ;
wire ShiftReg ;
wire Half;
wire Byte;
wire Immediate;
wire RegData_out;

wire Reg_write;
wire ReadData_1;
wire ReadData_2;

wire RegA_write;
wire ReadData_1;
wire RegA_out;

wire RegB_write;
wire ReadData_2;
wire RegB_out;

wire ALUSrcA_control;
wire ALUSrcA_out;

wire ALUSrcB_control;
wire SignExt;
wire ShiftLeft_2;
wire ALUSrcB_out;

wire AluToReg_control;
wire Flag;
wire AluToReg_out;

wire PCSource_control;
wire InstrunctionToPCSource;
wire Instr250_sl; // Igor vai mandar o shift left depois
assign InstrunctionToPCSource = {PC_out[31:28], Instr250_sl};
wire EPC;
wire Exception;
wire PCSource_out;

wire temp;

Registrador PC(clk, reset, PC_write, PC_in, PC_out);
Iord_mux Iord(Iord_control, PC_out, AluOut, Iord_out);
Memoria Mem(Iord_out, clk, Mem_write, Data_in, Data_out);
Instr_Reg Inst_reg(clk, reset, Load_ir, Data_out, Instr31_26, Instr25_21, Instr20_16, Instr15_0);
RegSrc_mux RedSrc(RegSrc_control, Instr25_21, RegSrc_out);
RegDst_mux RegDst(RegDst_control, Instr20_16, Instr15_0, RegDst_out);
RegData_mux RegData(RegData_control, MemData, Alu_Out, HI, LO, ShiftReg, Half, Byte, Immediate, RegData_out);
Banco_reg Reg_bank(clk, reset, Reg_write, RegSrc_out, Instr20_16, RegDst_out, RegData_out, ReadData_1, ReadData_2);
Registrador A(clk, reset, RegA_write, ReadData_1, RegA_out);
Registrador B(clk, reset, RegB_write, ReadData_2, RegB_out);
ALUSrcA_mux ALUSrcA(ALUSrcA_control, PC_out, RegA_out, ALUSrcA_out);
ALUSrcB_mux ALUSrcB(ALUSrcB_control, RegB_out, SignExt, ShiftLeft_2, ALUSrcB_out);
ula32 ALU(ALUSrcA_out, ALUSrcB_out, ALU_op, ALU_result, ALU_of, ALU_neg, ALU_z, ALU_eq, ALU_gt, ALU_lt);
AluToReg_mux AluToReg(AluToReg_control, ALU_result, Flag, AluToReg_out);
Registrador ALUout(clk, reset, ALUout_write, AluToReg_out, Alu_Out);
PCSource_mux PCSource(PCSource_control, ALU_result, Alu_Out, InstrunctionToPCSource, EPC, Exception, PCSource_out);
Unidade_Controle UnidadeControle(clk, reset_in, Instr31_26, Instr15_0[5:0], ALU_gt, ALU_lt, ALU_eq, ALU_of, ALU_neg, ALU_z,
 temp, reset, temp, PC_write, Mem_write, Load_ir, Reg_write, temp, temp, temp, ALUout_write, RegA_write, RegB_write, temp, temp, temp, Iord_control, temp, RegSrc_control, ALUSrcA_control, temp, temp, AluToReg_control, temp, 
 temp, temp, RegDst_control, ALUSrcB_control, ALU_op, temp, PCSource_control, RegData_control);

endmodule