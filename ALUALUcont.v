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
input signed [31:0]  in1,in2; //edited to signed
reg unsigned [31:0]  in1u,in2u;
input [3:0] aluop;
input [4:0] shamt;
output  reg  [31:0] out;
output reg zeroflag;
always @ (in1,in2,aluop)
begin

if(in1==in2)
zeroflag =1;
else
zeroflag=0;
//if(aluop==7)

in1u=in1;
in2u=in2;
case(aluop)
0: out=in1+in2;
1: out=in1-in2;
2: out=in1&in2;
3: out=in1|in2;
4 : out=in1<in2;
5 :out=in2*(2**shamt);
6 :out=in2/(2**shamt);
7 :out=in1u<in2u; 
endcase
end
endmodule 

/*
module	ALU_Test();
				reg	[31:0]	in1,	in2;
				 wire signed [31:0] 	OUT;
				wire	zeroflag;
				reg [3:0] aluop;
              reg [4:0] shamt;
              	reg	[5:0]	op,func;
              
				initial	begin
								in1	=	1;
								in2	=	2;
								#10 aluop= 0;
								#10 shamt=0;
								
				           
								#10	$display	("add out %d",	OUT);	$display	("flag %d",	zeroflag);
								#10	in1	=	1;	in2	=	2; aluop=1;
								#10	$display	("sub out %d",	OUT);	$display	("flag %d",	zeroflag);
								#10	in1	=	2'b10;	in2	=2'b11;aluop=2;
								#10	$display	("and out %d",	OUT);	$display	("flag %d",	zeroflag);
									#10	in1	=	2'b10;  in2	=2'b11;aluop=3;
								#10	$display	("or out %d",	OUT);	$display	("flag %d",	zeroflag);
									#10	in1	=	10;	in2	=	20;aluop=5; shamt=1;
								#10	$display	("shift** out %d",	OUT);	$display	("flag %d",	zeroflag);
									#10	in1	=	10;	in2	=	20;aluop=6; shamt=1;
								#10	$display	("shift/ out %d",	OUT);	$display	("flag %d",	zeroflag);
									#10	in1	=	20;	in2	=	20;aluop=6;
								#10	$display	("flag out %d",	OUT);	$display	("flag %d",	zeroflag);
									#10	in1	=	3;in2	=	-3 ;aluop=7;
								#10	$display	("ltu out %d",	OUT);	$display	("flag %d",	zeroflag);
								#10	in1	=-3;in2	=5;aluop=4;
								#10	$display	("lt out %d",	OUT);	$display	("flag %d",	zeroflag);
								
								
				end
				always@(in1,	in2,	aluop);
				ALU	aluTest(in1,in2,shamt,aluop,OUT,zeroflag);
endmodule
/*

/*
module	ALU_Test();
		//	reg	[31:0]	in1,b;
				reg	[5:0]	op,func;
				wire [3:0] ALUop;
				//reg [3:0] ALUopin;
			//	reg [4:0] shamt;
			//	wire	[31:0]	OUT;
			//	wire	zeroflag;
				initial	begin
							//	in1	=	1;
							//	b	=	2;
								#10 op=6'b000000;
								#10 func=6'b100000;
								//ALUop=2;
								#10	$display	("t1 %b",	ALUop);
							#10 op=6'b000000;
								#10 func=6'b100010;
								#10	$display	("t2 %b",	ALUop);
							
								
								
				end
				//always@(op, func) 
					//$display	("%b",	op);
				ALUcontrol	aluTest(func,op,ALUop);
endmodule
*/