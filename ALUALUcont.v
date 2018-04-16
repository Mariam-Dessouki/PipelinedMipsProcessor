//inst instead of op
module ALUcontrol(func,op,ALUop);
input [5:0] func,op;
output reg [3:0] ALUop;
always@(op, func)
	begin
		case({op,func})
			12'b000000100000: ALUop = 0; // Add
			12'b001000xxxxxx: ALUop = 0; // Addi
			12'b000000100010: ALUop = 1; // Sub
			12'b000000100100: ALUop = 2; // And
			12'b100011xxxxxx: ALUop = 0; // (Add) for lw
			12'b101011xxxxxx: ALUop = 0; // (Add) for sw
			12'b100101xxxxxx: ALUop = 0; // (Add) for lhu
			12'b100001xxxxxx: ALUop = 0; // (Add) for lh
			12'b000000000000: ALUop = 5; // sll
			12'b000000000010: ALUop = 6; // srl
			12'b000000100101: ALUop = 3; // or
			12'b000000101010: ALUop = 4; // slt
			12'b000000101011: ALUop = 7; // sltu
		endcase
	end
endmodule

module ALU (in1,in2,shamt,aluop,out,zeroflag);
input[31:0] in1,in2;
input [3:0] aluop;
input [4:0] shamt;
output reg [31:0] out;
output reg zeroflag;
always @ (in1,in2,aluop)
begin
if(in1==in2)
zeroflag =1;
else
zeroflag=0;
if(aluop==7)

case(aluop)
0: out=in1+in2;
1: out=in1-in2;
2: out=in1&in2;
3: out=in1|in2;
4 :out=in1<in2;
5 :out=in2*(2**shamt);
6 :out=in2/(2**shamt);
7 : out={1'b0,in1} < {1'b0,in2}; 
endcase
end
endmodule 