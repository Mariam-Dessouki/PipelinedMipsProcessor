module InstructionMemory(instruction, pc, clk);
output reg [31:0] instruction;
input [31:0] pc;
input clk;
reg [31:0] iMem [1023:0];
initial begin
iMem[0] =30;
end

always@(posedge clk)
begin
instruction = iMem[pc]; 
end

endmodule
