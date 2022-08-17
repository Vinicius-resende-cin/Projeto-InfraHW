module Unidade_Controle (
    input clock, RESET_in, // general inputs
    input [5:0] opcode, funct, // instruction inputs
    output RESET_out, BREAK, PCwrite, MemRead, MemWrite, IRwrite, RegWrite, MultOp, DivOp, EPCwrite, // 1 bit action signals
    output IorD, BHsel, RegSrc, ALUsrcA, ShamtSrc, ShiftData, ALUtoReg, MorDHI, MorDLO, // 1 bit MUX signals
    output [1:0] MemData, RedDst, ALUsrcB, // 2 bit MUX signals
    output [2:0] ALUop, ShiftOp, // 3 bit action signals
    output [2:0] PCsrc, // 3 bit MUX signals
    output [3:0] RegData // 4 bit MUX signal
);

    // internal reg
    reg [5:0] state; // state reg
    reg [4:0] counter; // state counter
    reg [5:0] next_state; // temp reg to store next state if needed

    // state definition
    parameter [5:0] RESET_s = 6'd0, // send RESET signal
                    RESETsp_s = 6'd1, // stores 227 in sp
                    BREAK_s = 6'd2, // stop the signals
                    PCread_s = 6'd3, // pc to mem; calculates pc+4;
                    MemWait_s = 6'd4, // wait for memory read
                    InstWrite_s = 6'd5, // write the instruction in the IR
                    InstDec_s = 6'd6, // get the registers rs, rt; calculates branch address
                    InstDecSP_s = 6'd7, // get the registers SP, rt;
                    ALUopSP_s = 6'd8, // ALU operation with SP
                    SPwrite_s = 6'd9, // write in SP from ALU
                    SPtoMem_s = 6'd10, // get memory address from SP
                    MemAdd_s = 6'd11, // memory address computation
                    MemRead_s = 6'd12, // read memory to memory data register
                    MemWrite_s = 6'd13, // write memory
                    BHsel_s = 6'd14, // select byte/half
                    MemToReg_s = 6'd15, // write register from memory
                    Jump_s = 6'd16, // load jump address in PC
                    StorePC_s = 6'd17, // store pc+4 address in ALUout register
                    JandSave_s = 6'd18, // jump address to PC; previous address to RA
                    PCtoEPC_s = 6'd19, // stores PC address in EPC register
                    RoutineC_s = 6'd20, // choose exception routine
                    GoToRout_s = 6'd21, // go to exception routine
                    RoutToPC_s = 6'd22, // load routine address in PC
                    LoadImd_s = 6'd23, // load immediate to a register
                    EPCtoPC_s = 6'd24, // load EPC address to PC
                    LoadLO_s = 6'd25, // load LO to a register
                    LoadHI_s = 6'd26, // load HI to a register
                    Compare_s = 6'd27, // compare rs and rt i ALU
                    ALUtoPC_s = 6'd28, // load ALU branch address to PC
                    ShiftReg_s = 6'd29, // load shift register with register amount
                    ShiftImd_s = 6'd30, // load shift register with immediate amount
                    ShiftOp_s = 6'd31, // shift operation
                    ShiftToReg_s = 6'd32, // write register from shift register
                    ALUjToPC_s = 6'd33, // load register's jump address from ALU to PC
                    ALUop_s = 6'd34, // operation wit registers in the ALU
                    ALUtoReg_s = 6'd35, // write ALU result in register
                    Div_s = 6'd36, // division
                    Mult_s = 6'd37, // multiplication
                    WriteHILO_s = 6'd38; // write in HI/LO registers

    // intruction definition
    parameter [5:0] j = (opcode == 6'h2),
                    jal = (opcode == 6'h3),
                    beq = (opcode == 6'h4),
                    bne = (opcode == 6'h5),
                    ble = (opcode == 6'h6),
                    bgt = (opcode == 6'h7),
                    addi = (opcode == 6'h8),
                    addiu = (opcode == 6'h9),
                    slti = (opcode == 6'ha),
                    lui = (opcode == 6'hf),
                    lb = (opcode == 6'h20),
                    lh = (opcode == 6'h21),
                    lw = (opcode == 6'h23),
                    sb = (opcode == 6'h28),
                    sh = (opcode == 6'h29),
                    sw = (opcode == 6'h2b),
                    // R format:
                    sll = (opcode == 6'h0 && funct == 6'h0),
                    srl = (opcode == 6'h0 && funct == 6'h2),
                    sra = (opcode == 6'h0 && funct == 6'h3),
                    sllv = (opcode == 6'h0 && funct == 6'h4),
                    push = (opcode == 6'h0 && funct == 6'h5),
                    pop = (opcode == 6'h0 && funct == 6'h6),
                    srav = (opcode == 6'h0 && funct == 6'h7),
                    jr = (opcode == 6'h0 && funct == 6'h8),
                    break = (opcode == 6'h0 && funct == 6'hd),
                    mfhi = (opcode == 6'h0 && funct == 6'h10),
                    mflo = (opcode == 6'h0 && funct == 6'h12),
                    rte = (opcode == 6'h0 && funct == 6'h13),
                    mult = (opcode == 6'h0 && funct == 6'h18),
                    div = (opcode == 6'h0 && funct == 6'h1a),
                    add = (opcode == 6'h0 && funct == 6'h20),
                    sub = (opcode == 6'h0 && funct == 6'h22),
                    _and = (opcode == 6'h0 && funct == 6'h24),
                    slt = (opcode == 6'h0 && funct == 6'h2a);

    // initial state
    initial begin
        state = PCread_s;
        counter = 4'd0;
    end

    // state selection
    always @(posedge clock, posedge RESET_in) begin
        if (RESET_in == 1) begin
            state = RESET_s;
        end

        case (state)
            RESET_s: begin
                state <= RESETsp_s;
            end
            RESETsp_s: begin
                state <= PCread_s;
            end
            BREAK_s: begin
                state <= BREAK_s;
            end
            PCread_s: begin
                state <= MemWait_s;
                next_state <= (opcode == Rformat && (funct == pop || funct == push))? InstDecSP_s : InstDec_s;
            end
            MemWait_s: begin
                state <= next_state;
            end
            InstDecSP_s: begin
                state <= (funct == push)? ALUopSP_s : MemAdd_s;
            end
            InstDec_s: begin
                state <= (break)? BREAK_s :
                         (lui)? LoadImd_s :
                         (rte)? EPCtoPC_s :
                         (mflo)? LoadLO_s :
                         (mfhi)? LoadHI_s :
                         (bne || beq || bgt || ble)? Compare_s :
                         (mult)? Mult_s :
                         (div)? Div_s :
                         (slti || addi || addiu || add || _and || sub || slt)? ALUop_s :
                         (jr)? ALUjToPC_s :
                         (sll || srl || sra)? ShiftImd_s :
                         (sllv || srav)? ShiftReg_s :
                         (lw || lh || lb || sw || sh || sb)? MemAdd_s :
                         (j)? Jump_s :
                         (jal)? JandSave_s :
                         PCtoEPC_s;
            end
            ...
            default: 
        endcase
    end

    // outputs selection
    always @(posedge clock, negedge RESET_in) begin
        
    end
endmodule