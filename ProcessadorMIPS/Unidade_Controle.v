module Unidade_Controle (
    input clock, RESET_in, // general inputs
    input [5:0] opcode, funct, // instruction inputs
    input GT, LT, ET, O, N, ZERO,// ALU inputs
    input Div0, // division/0
    output reg RESET_out, BREAK, PCwrite, MemWR, IRwrite, RegWrite, MultOp, DivOp, EPCwrite, ALUoutW, AW, BW, HIW, LOW, MemDataW, // 1 bit action signals
    output reg IorD, RegSrc, ALUsrcA, ShamtSrc, ShiftData, ALUtoReg, MorDHI, MorDLO, // 1 bit MUX signals
    output reg [1:0] MemData, RegDst, ALUsrcB, // 2 bit MUX signals
    output reg [2:0] ALUop, ShiftOp, // 3 bit action signals
    output reg [2:0] PCsrc, // 3 bit MUX signals
    output reg [3:0] RegData // 4 bit MUX signal
);

    // internal registers
    reg [5:0] state; // state reg
    reg [5:0] counter; // state counter
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
                    WriteHILO_s = 6'd38, // write in HI/LO registers
                    MemDataW_s = 6'd39; // write in mem data register

    // intruction definition
    reg j, jal, beq, bne, ble, bgt, addi, addiu, slti, lui, lb, lh, lw, sb, sh, sw, sll, srl, sra, sllv,
        push, pop, srav, jr, break, mfhi, mflo, rte, mult, div, add, sub, _and, slt;

    always @(posedge clock, posedge RESET_in) begin
        j = (opcode == 6'h2);
        jal = (opcode == 6'h3);
        beq = (opcode == 6'h4);
        bne = (opcode == 6'h5);
        ble = (opcode == 6'h6);
        bgt = (opcode == 6'h7);
        addi = (opcode == 6'h8);
        addiu = (opcode == 6'h9);
        slti = (opcode == 6'ha);
        lui = (opcode == 6'hf);
        lb = (opcode == 6'h20);
        lh = (opcode == 6'h21);
        lw = (opcode == 6'h23);
        sb = (opcode == 6'h28);
        sh = (opcode == 6'h29);
        sw = (opcode == 6'h2b);
        // R format:
        sll = (opcode == 6'h0 && funct == 6'h0);
        srl = (opcode == 6'h0 && funct == 6'h2);
        sra = (opcode == 6'h0 && funct == 6'h3);
        sllv = (opcode == 6'h0 && funct == 6'h4);
        push = (opcode == 6'h0 && funct == 6'h5);
        pop = (opcode == 6'h0 && funct == 6'h6);
        srav = (opcode == 6'h0 && funct == 6'h7);
        jr = (opcode == 6'h0 && funct == 6'h8);
        break = (opcode == 6'h0 && funct == 6'hd);
        mfhi = (opcode == 6'h0 && funct == 6'h10);
        mflo = (opcode == 6'h0 && funct == 6'h12);
        rte = (opcode == 6'h0 && funct == 6'h13);
        mult = (opcode == 6'h0 && funct == 6'h18);
        div = (opcode == 6'h0 && funct == 6'h1a);
        add = (opcode == 6'h0 && funct == 6'h20);
        sub = (opcode == 6'h0 && funct == 6'h22);
        _and = (opcode == 6'h0 && funct == 6'h24);
        slt = (opcode == 6'h0 && funct == 6'h2a);
    end

    // initial state
    initial begin
        state = RESET_s;
        counter = 6'd0;
    end

    // initial outputs
    initial begin
        // 1 bit action signals
        RESET_out = 1'b0;
        BREAK = 1'b0;
        PCwrite = 1'b0;
        MemWR = 1'b0;
        IRwrite = 1'b0;
        RegWrite = 1'b0;
        MultOp = 1'b0;
        DivOp = 1'b0;
        EPCwrite = 1'b0;
        ALUoutW = 1'b0;
        AW = 1'b0;
        BW = 1'b0;
        HIW = 1'b0;
        LOW = 1'b0;
        MemDataW = 1'b0;

        // 1 bit MUX signals
        IorD = 1'b0;
        RegSrc = 1'b0;
        ALUsrcA = 1'b0;
        ShamtSrc = 1'b0;
        ShiftData = 1'b0;
        ALUtoReg = 1'b0;
        MorDHI = 1'b0;
        MorDLO = 1'b0;
        
        // 2 bit MUX signals
        MemData = 2'b00;
        RegDst = 2'b00;
        ALUsrcB = 2'b00;

        // 3 bit action signals
        ALUop = 3'b000;
        ShiftOp = 3'b000;

        // 3 bit MUX signal
        PCsrc = 3'b000;

        // 4 bit mux signal
        RegData = 4'b0000;
    end

    // state selection
    always @(posedge clock, posedge RESET_in) begin
        if (RESET_in == 1) begin
            state = RESET_s;
        end else begin
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
                    next_state = InstWrite_s;
                end
                InstWrite_s: begin
                    state <= (pop || push)? InstDecSP_s : InstDec_s;
                end
                MemWait_s: begin
                    state <= next_state;
                    next_state <= 6'bz;
                end
                InstDecSP_s: begin
                    state <= (push)? ALUopSP_s : MemAdd_s;
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
                ALUopSP_s: begin
                    state <= SPwrite_s;
                end
                SPwrite_s: begin
                    state <= (push)? SPtoMem_s : PCread_s;
                end
                SPtoMem_s: begin
                    state <= MemWrite_s;
                end
                MemAdd_s: begin
                    state <= (sw)? MemWrite_s : MemRead_s;
                end 
                MemRead_s: begin
                    state <= MemWait_s;
                    next_state <= MemDataW_s;
                end
                MemDataW_s: begin
                    state <= (lw || lh || lb || pop)? MemToReg_s : MemWrite_s;
                end
                MemWrite_s: begin
                    state <= PCread_s;
                end
                MemToReg_s: begin
                    state <= (pop)? ALUopSP_s : PCread_s;
                end 
                Jump_s: begin
                    state <= PCread_s;
                end
                StorePC_s: begin
                    state <= JandSave_s;
                end
                JandSave_s: begin
                    state <= PCread_s;
                end
                PCtoEPC_s: begin
                    state <= RoutineC_s;
                end
                RoutineC_s: begin
                    state <= GoToRout_s;
                end
                GoToRout_s: begin
                    state <= MemWait_s;
                    next_state = RoutToPC_s;
                end
                RoutToPC_s: begin
                    state <= PCread_s;
                end
                LoadImd_s: begin
                    state <= PCread_s;
                end
                EPCtoPC_s: begin
                    state <= PCread_s;
                end
                LoadLO_s: begin
                    state <= PCread_s;
                end 
                LoadHI_s: begin
                    state <= PCread_s;
                end 
                Compare_s: begin
                    state <= (bne)? ((ET)? PCread_s : ALUtoPC_s) :
                            (beq)? ((ET)? ALUtoPC_s : PCread_s) :
                            (bgt)? ((GT)? ALUtoPC_s : PCread_s) :
                            (ble)? ((LT)? ALUtoPC_s : PCread_s) :
                            6'bx;
                end
                ALUtoPC_s: begin
                    state <= PCread_s;
                end
                ShiftReg_s: begin
                    state <= ShiftOp_s;
                end 
                ShiftImd_s: begin
                    state <= ShiftOp_s;
                end 
                ShiftOp_s: begin
                    state <= ShiftToReg_s;
                end
                ShiftToReg_s: begin
                    state <= PCread_s;
                end
                ALUjToPC_s: begin
                    state <= PCread_s;
                end 
                ALUop_s: begin
                    state <= ALUtoReg_s;
                end
                ALUtoReg_s: begin
                    state <= PCread_s;
                end 
                Div_s: begin
                    state <= (Div0)? PCtoEPC_s : ((counter == 6'd32)? WriteHILO_s : Div_s);
                    counter = (Div0)? 6'd0 : counter + 1;
                end
                Mult_s: begin
                    state <= (counter == 6'd32)? WriteHILO_s : Mult_s;
                    counter = counter + 1;
                end
                WriteHILO_s: begin
                    counter = 6'd0;
                    state <= PCread_s;
                end
                default: state <= BREAK_s;
            endcase
        end
    end

    // outputs selection
    always @(state) begin
        // reset action signals
        RESET_out = 1'b0;
        PCwrite = 1'b0;
        MemWR = 1'b0;
        IRwrite = 1'b0;
        RegWrite = 1'b0;
        MultOp = 1'b0;
        DivOp = 1'b0;
        EPCwrite = 1'b0;
        ALUoutW = 1'b0;
        AW = 1'b0;
        BW = 1'b0;
        HIW = 1'b0;
        LOW = 1'b0;
        MemDataW = 1'b0;
        BREAK = 1'b0;

        case (state)
            RESET_s: begin
                RESET_out = 1'b1;
            end
            RESETsp_s: begin
                RegData = 4'b0000;
                RegDst = 2'b10;
                RegWrite = 1;
            end
            BREAK_s: begin
                BREAK = 1'b1;
            end
            PCread_s: begin
                ALUsrcA = 1'b0;
                ALUsrcB = 2'b01;
                ALUop = 3'b001;
                PCsrc = 3'b000;
                IorD = 1'b0;
                MemWR = 1'b0;
            end
            MemWait_s: begin
                MemWR = 1'b0;
            end
            InstWrite_s: begin
                IRwrite = 1'b1;
                PCwrite = 1'b1;
            end
            InstDecSP_s: begin
                RegSrc = 1'b0;
                AW = 1'b1;
                BW = 1'b1;
                ALUsrcA = 1'b0;
                ALUsrcB = 2'b11;
                ALUop = 3'b001;
                ALUtoReg = 1'b0;
                ALUoutW = 1'b1;
            end
            InstDec_s: begin
                RegSrc = 1'b1;
                AW = 1'b1;
                BW = 1'b1;
                ALUsrcA = 1'b0;
                ALUsrcB = 2'b11;
                ALUop = 3'b001;
                ALUtoReg = 1'b0;
                ALUoutW = 1'b1;
            end
            ALUopSP_s: begin
                ALUsrcA = 1'b1;
                ALUsrcB = 2'b01;
                ALUop = 3'b010;
                ALUtoReg = 1'b0;
                ALUoutW = 1'b1;
            end
            SPwrite_s: begin
                RegData = 4'b0010;
                RegDst = 2'b10;
                RegWrite = 1'b1;
            end
            SPtoMem_s: begin
                ALUsrcA = 1'b1;
                ALUop = 3'b000;
                ALUtoReg = 1'b0;
                ALUoutW = 1'b1;
                IorD = 1'b1;
            end
            MemAdd_s: begin
                ALUsrcA = 1'b1;
                ALUsrcB = 2'b10;
                ALUop = 3'b001;
                ALUtoReg = 1'b0;
                ALUoutW = 1'b1;
                IorD = 1'b1;
            end 
            MemRead_s: begin
                MemWR = 1'b0;
            end
            MemDataW_s: begin
                MemDataW = 1'b1;
            end
            MemWrite_s: begin
                MemData = (push || sw)? 2'b00 : ((sh)? 2'b01 : 2'b10);
                MemWR = 1'b1;
            end
            MemToReg_s: begin
                RegData = (lw || pop)? 4'b0001 : ((lh)? 4'b0110 : 4'b0111);
                RegDst = 2'b00;
                RegWrite = 1'b1; 
            end 
            Jump_s: begin
                PCsrc = 3'b010;
                PCwrite = 1'b1;
            end
            StorePC_s: begin
                ALUsrcA = 1'b0;
                ALUop = 3'b000;
                ALUtoReg = 1'b0;
                ALUoutW = 1'b1;
            end
            JandSave_s: begin
                PCsrc = 3'b010;
                PCwrite = 1'b1;
                RegData = 4'b0010;
                RegDst = 2'b11;
                RegWrite = 1'b1;
            end
            PCtoEPC_s: begin
                ALUsrcA = 1'b0;
                ALUsrcB = 2'b01;
                ALUop = 3'b010;
                EPCwrite = 1'b1;
            end
            RoutineC_s: begin
                PCsrc = (div && Div0)? 3'b111 : ((O)? 3'b110 : 3'b101);
                PCwrite = 1'b1; 
            end
            GoToRout_s: begin
                IorD = 1'b0;
                MemWR = 1'b0;
            end
            RoutToPC_s: begin
                PCsrc = 3'b100;
                PCwrite = 1'b1;
            end
            LoadImd_s: begin
                RegData = 4'b1000;
                RegDst = 2'b00;
                RegWrite = 1'b1;
            end
            EPCtoPC_s: begin
                PCsrc = 3'b011;
                PCwrite = 1'b1;
            end
            LoadLO_s: begin
                RegData = 4'b0100;
                RegDst = 2'b01;
                RegWrite = 1'b1;
            end 
            LoadHI_s: begin
                RegData = 4'b0011;
                RegDst = 2'b01;
                RegWrite = 1'b1;
            end 
            Compare_s: begin
                ALUsrcA = 1'b1;
                ALUsrcB = 2'b00;
                ALUop = 3'b111;
            end
            ALUtoPC_s: begin
                PCsrc = 3'b001;
                PCwrite = 1'b1;
            end
            ShiftReg_s: begin
                ShiftData = 1'b0;
                ShamtSrc = 1'b1;
                ShiftOp = 001;
            end 
            ShiftImd_s: begin
                ShiftData = 1'b1;
                ShamtSrc = 1'b0;
                ShiftOp = 001;
            end 
            ShiftOp_s: begin
                ShiftOp = (sll || sllv)? 3'b010 : ((srl)? 3'b011 : 3'b100);
            end
            ShiftToReg_s: begin
                RegData = 4'b0101;
                RegDst = 2'b01;
                RegWrite = 1'b1;
            end
            ALUjToPC_s: begin
                ALUsrcA = 1'b1;
                ALUsrcB = 2'b00;
                ALUop = 3'b000;
                PCsrc = 3'b000;
                PCwrite = 1'b1;
            end 
            ALUop_s: begin
                ALUsrcA = 1'b1;
                ALUsrcB = (addi || addiu || slti)? 2'b10 : 2'b00;
                ALUop = (add || addi || addiu)? 3'b001 :
                        (sub)? 3'b010 :
                        (slt || slti)? 3'b111 :
                        3'b011;
                ALUtoReg = (slt || slti)? 1'b1 : 1'b0;
                ALUoutW = 1'b1;
            end
            ALUtoReg_s: begin
                RegData = 4'b0010;
                RegDst = 2'b01;
                RegWrite = 1'b1;
            end 
            Div_s: begin
                DivOp = 1'b1;
            end
            Mult_s: begin
                MultOp = 1'b1;
            end
            WriteHILO_s: begin
                MorDHI = (mult)? 1'b0 : 1'b1;
                MorDLO = (mult)? 1'b0 : 1'b1;
                HIW = 1'b1;
                LOW = 1'b1;
            end
        endcase
    end
endmodule