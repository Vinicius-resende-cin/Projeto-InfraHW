module Divisor(clk, rst, start, A, B, high, low, div0);

input clk, rst, start;
input [31:0] A, B;
output [31:0] high, low;
output div0;

reg pres_state, next_state, sign;
reg [31:0] A_, next_A, B_, next_B, R, next_R, Q, next_Q;
reg [5:0] counter, next_counter;

assign high = R;
assign low = Q;
assign div0 = (B == 32'd0);

parameter IDLE = 1'b0;
parameter START = 1'b1;

always @(posedge clk, posedge rst) begin
    if (rst) begin
        pres_state <= 1'b0;
        A_ <= 32'd0;
        B_ <= 32'd0;
        R <= 32'd0;
        Q <= 32'd0;
        counter <= 6'd0;
        sign <= 1'b0;
    end else begin
        pres_state <= next_state;
        A_ <= next_A;
        B_ <= next_B;
        R <= (counter == 6'd32)? R : next_R;
        Q <= (counter == 6'd32)? Q : next_Q;
        counter <= next_counter;
    end
end

always @(*) begin
    case (pres_state)
        IDLE: begin
            next_counter = 6'd0;

            if(start && ~div0) begin
                next_state = START;
                sign = A[31] ^ B[31];
                next_A = (A[31])? ~A + 1 : A;
                next_B = (B[31])? ~B + 1 : B;
            end else begin
                next_state = pres_state;
                next_A = 32'd0;
                next_B = 32'd0;
            end

            next_R = 32'd0;
            next_Q = 32'd0;
        end
        START: begin
            next_R = next_R << 1;
            next_Q = next_Q << 1;

            next_R[0] = A_[31];

            if (next_R < B_) begin
                next_Q[0] = 1'b0;
            end else begin
                next_Q[0] = 1'b1;
                next_R = next_R - B_;
            end

            next_A = A_ << 1;
            next_counter = counter + 1;
            next_state = (counter == 6'd32)? IDLE : pres_state;
            
            next_Q = (next_counter == 6'd32 && sign == 1'b1)? ~next_Q + 1 : next_Q;
            next_R = (next_counter == 6'd32 && A[0])? ~next_R + 1 : next_R;
        end
    endcase
end
endmodule