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

    // state definition
    parameter [5:0] RESET_s = 6'd0, // send RESET signal
                    RESETsp_s = 6'd1, // stores 227 in sp
                    BREAK_s = 6'd2, // stop to send signals
                    PCread_s = 6'd3, // pc to mem; calculates pc+4;
                    InstWrite_s = 6'd4, // write the instruction in the IR
                    InstDec_s = 6'd5, // get the registers rs, rt; calculates branch address
                    InstDecSP_s = 6'd6, // get the registers SP, rt;
                     = 6'd7,
                     = 6'd8,
                     = 6'd9,
                     = 6'd10,
                     = 6'd11,
                     = 6'd12,
                     = 6'd13,
                     = 6'd14,
                     = 6'd15,
                     = 6'd16,
                     = 6'd17,
                     = 6'd18,
                     = 6'd19,
                     = 6'd20,
                     = 6'd21,
                     = 6'd22,
                     = 6'd23,
                     = 6'd24,
                     = 6'd25,
                     = 6'd26,
                     = 6'd27,
                     = 6'd28,
                     = 6'd29,
                     = 6'd30,
                     = 6'd31,
                     = 6'd32,
                    ...

    // opcode definition
    parameter [5:0] Rformat = 6'h0,
                    j = 6'h2,
                    jal = 6'h3,
                    beq = 6'h4,
                    bne = 6'h5,
                    ble = 6'h6,
                    bgt = 6'h7,
                    addi = 6'h8,
                    addiu = 6'h9,
                    slti = 6'ha,
                    lui = 6'hf,
                    lb = 6'h20,
                    lh = 6'h21,
                    lw = 6'h23,
                    sb = 6'h28,
                    sh = 6'h29,
                    sw = 6'h2b;

    // funct definition
    parameter [5:0] sll = 6'h0,
                    srl = 6'h2,
                    sra = 6'h3,
                    sllv = 6'h4,
                    push = 6'h5,
                    pop = 6'h6,
                    srav = 6'h7,
                    jr = 6'h8,
                    break = 6'hd,
                    mfhi = 6'h10,
                    mflo = 6'h12,
                    rte = 6'h13,
                    mult = 6'h18,
                    div = 6'h1a,
                    add = 6'h20,
                    sub = 6'h22,
                    _and = 6'h24,
                    slt = 6'h2a;

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
                if (counter < 4'd1) begin // wait for memory
                    state <= PCread_s;
                    counter = counter + 1;
                end else if (counter == 4'd1) begin
                    state <= (opcode == Rformat && (funct == pop || funct == push))? InstDecSP_s : InstDec_s; // select rs or SP
                    counter = 4'd0;
                end
            end
            InstDecSP_s: begin
                
            end
            InstDec_s: begin
                
            end
            ...
            default: 
        endcase
    end

    // outputs selection
    always @(posedge clock, negedge RESET_in) begin
        
    end
endmodule