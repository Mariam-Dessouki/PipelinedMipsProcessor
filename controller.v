//////// andi ori

module controller(inst,RegDst,Branch,MemRead,MemtoReg,MemWrite,ALUSrc,RegWrite);

input [5:0] inst;
output reg RegDst,Branch,MemtoReg,MemWrite,ALUSrc,RegWrite;
output reg [1:0] MemRead;

always@(inst)
begin
case(inst)
6'b000000:begin RegDst=1;RegWrite=1;Branch=0;MemRead=0;MemtoReg=0;MemWrite=0;ALUSrc=0; end//add addi and or sll srl slt sltu
6'b001000:begin RegDst=0;RegWrite=1;Branch=0;MemRead=0;MemtoReg=0;MemWrite=0;ALUSrc=1; end//addi
6'b100011:begin RegDst=0;RegWrite=1;Branch=0;MemRead=1;MemtoReg=1;MemWrite=0;ALUSrc=1; end//lw
6'b100001:begin RegDst=0;RegWrite=1;Branch=0;MemRead=2;MemtoReg=1;MemWrite=0;ALUSrc=1; end//lh
6'b100101:begin RegDst=0;RegWrite=1;Branch=0;MemRead=3;MemtoReg=1;MemWrite=0;ALUSrc=1; end//lhu
6'b101011:begin RegDst=1'bx;RegWrite=0;Branch=0;MemRead=0;MemtoReg=1'bx;MemWrite=1;ALUSrc=1; end//sw
6'b000100:begin RegDst=1'bx;RegWrite=0;Branch=1;MemRead=0;MemtoReg=1'bx;MemWrite=0;ALUSrc=0; end//beq
endcase
end

endmodule 