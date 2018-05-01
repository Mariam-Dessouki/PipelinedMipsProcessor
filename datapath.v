module Adder(in, out ,clk);
output reg [31:0] out;
input [31:0] in;
input clk;

//always @* begin
//$display ("in %b clk %b",in,clk);
//end

always@(in)
	begin
		out=in+4;
	end
endmodule 
 
//inst instead of op
module ALUcontrol(func,op,ALUop);
input [5:0] func,op;
output reg [3:0] ALUop;
always@(op, func)
	begin
	//$display("op, %b, func %b, Aluop %b", op, func,ALUop);
	    if( (op== 6'b001000) || (op == 6'b100011) || (op == 6'b101011) || (op == 6'b100101) || (op == 6'b100001))
	    ALUop = 0;
	    else if(op == 6'b001100)
	            ALUop=2;
	    else if(op == 6'b001101)
	            ALUop=3;
	    else
	        begin
		        case({op,func})
		           
			        12'b000000100000: ALUop = 0; // Add
			        //12'b001000xxxxxx: ALUop = 0; // Addi
			        12'b000000100010: ALUop = 1; // Sub
			        12'b000000100100: ALUop = 2; // And
			        //12'b100011xxxxxx: ALUop = 0; // (Add) for lw
		            //	12'b101011xxxxxx: ALUop = 0; // (Add) for sw
		            //	12'b100101xxxxxx: ALUop = 0; // (Add) for lhu
			        //12'b100001xxxxxx: ALUop = 0; // (Add) for lh
			        12'b000000000000: ALUop = 5; // sll
			        12'b000000000010: ALUop = 6; // srl
			        12'b000000100101: ALUop = 3; // or
			        12'b000000101010: ALUop = 4; // slt
			        12'b000000101011: ALUop = 7; // sltu
		        endcase
		end
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
//$display("in1 %b, in2 %b, aluop %b", in1, in2, aluop); 
if(in1==in2)
zeroflag <=1;
else
zeroflag <=0;
//if(aluop==7)
 
in1u=in1;
in2u=in2;
//$display(" outalu %b",out);
case(aluop)
0: out<=in1+in2;
1: out<=in1-in2;
2: out<=in1&in2;
3: out<=in1|in2;
4 : out<=in1<in2;
5 :out<=in2*(2**shamt);
6 :out<=in2/(2**shamt);
7 :out<=in1u<in2u; 
endcase
end
endmodule 
 
module BranchAdder(out,in1,in2);
output reg [31:0] out;
input [31:0] in1,in2;
always @(in1 , in2)
out = in1 + in2;
 
endmodule
 
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
6'b001100:begin RegDst=0;RegWrite=1;Branch=0;MemRead=0;MemtoReg=0;MemWrite=0;ALUSrc=1; end//andi
6'b001101:begin RegDst=0;RegWrite=1;Branch=0;MemRead=0;MemtoReg=0;MemWrite=0;ALUSrc=1; end//ori
6'b100011:begin RegDst=0;RegWrite=1;Branch=0;MemRead=1;MemtoReg=1;MemWrite=0;ALUSrc=1; end//lw
6'b100001:begin RegDst=0;RegWrite=1;Branch=0;MemRead=2;MemtoReg=1;MemWrite=0;ALUSrc=1; end//lh
6'b100101:begin RegDst=0;RegWrite=1;Branch=0;MemRead=3;MemtoReg=1;MemWrite=0;ALUSrc=1; end//lhu
6'b101011:begin RegDst=1'bx;RegWrite=0;Branch=0;MemRead=0;MemtoReg=1'bx;MemWrite=1;ALUSrc=1; end//sw
6'b000100:begin RegDst=1'bx;RegWrite=0;Branch=1;MemRead=0;MemtoReg=1'bx;MemWrite=0;ALUSrc=0; end//beq
endcase
end
 
endmodule 
 
module DataMemory(address,writeData,memWrite,clk,memRead,readData);
input [31:0] address,writeData;
input memWrite;
input[1:0] memRead;
input clk;
output reg [31:0] readData;
reg[7:0] dMem[1023:0];
initial begin
dMem[4] =8'b00000000;
dMem[5] =8'b00000000;
dMem[6] =8'b00000000;
dMem[7] =8'b00001010;
dMem[10]=8'b10000001;
dMem[11]=8'b10000111;
dMem[12]=8'b00000011;
dMem[13]=8'b10100111;
dMem[14]=8'b00101011;
dMem[15]=8'b11101011; //up to 19
end

always@(posedge clk)
	begin
	if(memWrite)//sw
	   begin
	    $display("writedata %b",writeData);
		dMem[address]= writeData[31:24];
		dMem[address+1]= writeData[23:16];
		dMem[address+2]= writeData[15:8];
		dMem[address+3]= writeData[7:0];
	   end
	end
always@(address, memRead)
	begin
	    if(memRead==1)//lw
	    begin
		     readData[31:24]=dMem[address];
		     readData[23:16]=dMem[address+1];
		     readData[15:8]=dMem[address+2];
		     readData[7:0]=dMem[address+3];
		 end
		else if(memRead==2)
	    begin
		    if(dMem[address][7:7]) //lh
				readData = {16'b1111111111111111,dMem[address],dMem[address+1]};
				
			else if(dMem[address][7:7]==0)
				readData = {16'b0000000000000000,dMem[address],dMem[address+1]};	
		end
		else if(memRead==3)//lhu
		    readData = {16'b0000000000000000,dMem[address],dMem[address+1]};
		    
		else
		    readData = 32'bxxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx;
 
	end
 
endmodule 
 
module InstructionMemory(instruction, pc, clk);
output reg [31:0] instruction;
input [31:0] pc;
input clk;
reg [31:0] iMem [1023:0];
initial begin
iMem[0] =32'b000000_01010_00000_01001_00000_100000;//add $t1,$t2,$0
iMem[4] =32'b10001110001010110000000000000000;//lw $t3,0($s1)
iMem[8] =32'b100101_01100_01000_0000_0000_0000_0001;//lhu $t0,1($t4)
iMem[12]=32'b100001_01110_01101_0000_0000_0000_0010;//lh $t5,2($t6)
iMem[16]=32'b101011_01111_10000_0000000000000000;//sw $s0,0($t7)
iMem[20]=32'b000000_01010_01100_10010_00000_100010;//sub $s2, $t2, $t4
iMem[24]=32'b000000_01010_01100_10011_00000_100100;//and $s3, $t2, $t4
iMem[28]=32'b000000_01010_01100_10100_00000_100101;//or $s4, $t2, $t4
iMem[32]=32'b000000_00000_01100_10101_00011_000000;//sll $s5, $t4, 3
iMem[36]=32'b000000_00000_01100_10110_00010_000010;//srl $s6, $t4, 2
iMem[40]=32'b001000_01100_10111_11111_11111_110110;//addi $s7, $t4, -10
iMem[44]=32'b000000_01010_01100_11000_00000_101010;//slt $t8, $t2, $t4 
iMem[48]=32'b000000_01010_00010_11001_00000_101011;//sltu $t9, $t2, $v0
iMem[52]=32'b001100_01100_00101_00000_00000_001000;//andi $a1, $t4, 8
iMem[56]=32'b001101_01100_00110_00000_00000_001000;//ori $a2, $t4, 8
iMem[60]=32'b000000_01100_01010_00111_00000_100000;//add $a3, $t4,$t2
iMem[64]=32'b000000_00111_01100_11010_00000_100010;//sub $k0, $a3, $t4
iMem[68]=32'b000000_01010_01100_10100_00000_100101;//or $s4, $t2, $t4
iMem[72]=32'b000100_00011_00100_11111_11111_101100;//beq $v1,$a0,0 


end

//always @(posedge clk) begin
//$display ("pc at imem %b clk %b",pc,clk);
//end
 
always@(posedge clk)
begin
instruction <= iMem[pc]; 
end
 
endmodule
 
module Mux5(in1, in2, switch,  out);
output reg [4:0] out;
input [4:0] in1, in2;
input switch;
 
always@(switch,in1,in2)
	begin
		case(switch)
		0: out<=in1;
		1: out<=in2;
		endcase
	end
 
 
endmodule 
 
module Mux32(in1, in2, switch,  out);
output reg [31:0] out;
input [31:0] in1, in2;
input switch;
 
always@(switch,in1,in2)
	begin
		case(switch)
		0: out<=in1;
		1: out<=in2;
		endcase
	end
 
 
endmodule 
 
module registerFile( clk , rs , rt , rd , writeData , regWrite , Data1 , Data2 , Answer);
    input [4:0] rs ,rt , rd;
    input [31:0] writeData;
    input regWrite;
    input clk;
    output reg [31:0] Data1,Data2,Answer;
    reg [31:0] registers [31:0];
    
    initial begin
       registers[2]  =32'b11111111111111111000000011100111;
       registers[3]  =32'b00000000000000000000000000000111;
       registers[4]  =32'b00000000000000000000000000000111;
       registers[10] =32'b00000000000000000000000000000101;
       registers[12] =32'b00000000000000000000000000001001;
       registers[14] =32'b00000000000000000000000000001011;
       registers[15] =32'b00000000000000000000000000001111;
       registers[16] =32'b00000000000000000000000000010001;
       registers[17] =32'b00000000000000000000000000000100;
    end
    always @(rs, rt)
    begin
        Data1 <= (rs==0)? 32'b0 : registers[rs];
        Data2 <= (rt==0)? 32'b0 : registers[rt];
    end
    always @ (posedge clk)
    begin 
    if(regWrite)
        registers [rd] <= writeData;
        Answer <= writeData ;
    end
endmodule 
 
 
module signExtension(out,in);
output reg [31:0] out;
input[15:0] in;
always @(in)
out = (in[15])? {16'b1111111111111111,in} : {16'b0000000000000000,in};
endmodule

module pcCounter(newPc , clk , pc);
output reg [31:0] pc;
input clk;
input[31:0] newPc;
always @ (posedge clk) begin
pc =0;
begin
pc = newPc;
end
end
endmodule

///////////////////////////PIPELINING STARTS HERE/////////////////////////////////

module IF_ID(Hazard,currentInstruction, currentPC, clk, newInstruction, newPC);
output reg[31:0] newInstruction, newPC;
input [31:0] currentInstruction, currentPC;
input clk,Hazard;

initial
    begin
        newInstruction=32'b0000_0000_0000_0000_0000_0000_0000_0000;
        newPC = 32'b0000_0000_0000_0000_0000_0000_0000_0000;
    end

always@(posedge clk)
    begin
   // $display("IF/ID_Instruction %d ,IF/ID_PC %d " ,newInstruction, newPC);
    if(Hazard ==1)
        begin
            newInstruction <= currentInstruction;
            newPC <= currentPC;
        end
    end

endmodule

module ID_EX(cSignExtend, cReadData1, cReadData2, cPC,cRs, cRt, cRd, cShamt, cOp, cFunc,
cRegDst,cBranch,cMemRead,cMemtoReg,cMemWrite,cALUSrc,cRegWrite, clk, nSignExtend, nReadData1, nReadData2, nPC,nRs, nRt, nRd, nShamt, nOp, nFunc,
nRegDst,nBranch,nMemRead,nMemtoReg,nMemWrite,nALUSrc,nRegWrite);

input [31:0] cSignExtend, cReadData1, cReadData2, cPC;
input [4:0] cRs,cRt, cRd, cShamt;
input [5:0] cOp, cFunc;
input cRegDst,cBranch,cMemtoReg,cMemWrite,cALUSrc,cRegWrite, clk;
input [1:0] cMemRead;
output reg [31:0] nSignExtend, nReadData1, nReadData2, nPC;
output reg [4:0] nRs,nRt, nRd, nShamt;
output reg [5:0] nOp, nFunc;
output reg nRegDst,nBranch,nMemtoReg,nMemWrite,nALUSrc,nRegWrite;
output reg [1:0] nMemRead;

initial
    begin
        nSignExtend <= 0;
        nReadData1 <= 0;
        nReadData2 <= 0;
        nPC <= 0;
        nRt <= 0;
        nRd <= 0;
        nRs<=0;
        nShamt <= 0;
        nOp <= 0;
        nFunc <= 0;
        nRegDst <= 0;
        nBranch <= 0;
        nMemtoReg <= 0;
        nMemWrite <= 0;
        nALUSrc <= 0;
        nRegWrite <= 0;
        nMemRead <= 0;
    end

always @ (posedge clk)
    begin
      //  $display(" ID_EX_SignExtend %d , ID_EX_ReadData1 %d , ID_EX_ReadData2 %d , ID_EX_PC %d ,ID_EX_Rs %d , ID_EX_Rt %d , ID_EX_Rd %d , ID_EX_Shamt %d , ID_EX_Op %d , ID_EX_Func %d ,ID_EX_RegDst %d ,ID_EX_Branch %d ,ID_EX_MemRead %d ,ID_EX_MemtoReg %d ,ID_EX_MemWrite %d ,ID_EX_ALUSrc %d ,ID_EX_RegWrite %d" ,nSignExtend, nReadData1, nReadData2, nPC,nRs, nRt, nRd, nShamt, nOp, nFunc,
//nRegDst,nBranch,nMemRead,nMemtoReg,nMemWrite,nALUSrc,nRegWrite);
        nSignExtend <= cSignExtend;
        nReadData1 <= cReadData1;
        nReadData2 <= cReadData2;
        nPC <= cPC;
        nRt <= cRt;
        nRd <= cRd;
        nRs <= cRs;
        nShamt <= cShamt;
        nOp <= cOp;
        nFunc <= cFunc;
        nRegDst <= cRegDst;
        nBranch <= cBranch;
        nMemtoReg <= cMemtoReg;
        nMemWrite <= cMemWrite;
        nALUSrc <= cALUSrc;
        nRegWrite <= cRegWrite;
        nMemRead <= cMemRead;
    end

endmodule


module EX_MEM(clk, cWriteData, cPC, cWriteRegister, cRegWrite, cMemtoReg, cALUResult, cMemWrite, cMemRead, cBranch, cZeroFlag, 
nWriteData, nPC, nWriteRegister, nRegWrite, nMemtoReg, nALUResult, nMemWrite, nMemRead, nBranch, nZeroFlag);

input [31:0] cWriteData, cPC, cALUResult;
input [4:0] cWriteRegister;
input [1:0] cMemRead;
input clk, cRegWrite, cMemtoReg, cMemWrite, cBranch, cZeroFlag;

output reg [31:0] nWriteData, nPC, nALUResult;
output reg [4:0] nWriteRegister;
output reg [1:0] nMemRead;
output reg nRegWrite, nMemtoReg, nMemWrite, nBranch, nZeroFlag;


initial
    begin
        nWriteData<=0;
        nPC<= 0;
        nALUResult <= 0;
        nWriteRegister<=0;
        nMemRead <= 0;
        nRegWrite<=0;
        nMemtoReg<=0;
        nMemWrite<= 0;
        nBranch <= 0;
        nZeroFlag <= 0;
    end

always@(posedge clk)
    begin
   // $display("EX_MEM_WriteData %d, EX_MEM_PC %d, EX_MEM_WriteRegister %d, EX_MEM_RegWrite %d, EX_MEM_MemtoReg %d, EX_MEM_ALUResult %d, EX_MEM_MemWrite %d, EX_MEM_MemRead %d, EX_MEM_Branch %d, EX_MEM_ZeroFlag %d",nWriteData, nPC, nWriteRegister, nRegWrite, nMemtoReg, nALUResult, nMemWrite, nMemRead, nBranch, nZeroFlag);
        nWriteData<=cWriteData;
        nPC<= cPC;
        nALUResult <= cALUResult;
        nWriteRegister<=cWriteRegister;
        nMemRead <= cMemRead;
        nRegWrite<=cRegWrite;
        nMemtoReg<=cMemtoReg;
        nMemWrite<= cMemWrite;
        nBranch <= cBranch;
        nZeroFlag <= cZeroFlag;
    end

endmodule


module MEM_WB(cMemtoReg, cRegWrite, cWriteRegister, cALUResult, cReadData, clk, nMemtoReg, nRegWrite, nWriteRegister, nALUResult, nReadData);

input [31:0] cALUResult, cReadData;
input [4:0] cWriteRegister;
input cMemtoReg, cRegWrite, clk;

output reg [31:0] nALUResult, nReadData;
output reg [4:0] nWriteRegister;
output reg nMemtoReg, nRegWrite;

initial
    begin
        nALUResult<=0;
        nReadData<=0;
        nWriteRegister<=0;
        nMemtoReg<=0;
        nRegWrite<=0;
    end

always@(posedge clk)
    begin
   // $display("MEM_WB_MemtoReg %d , MEM_WB_RegWrite %d , MEM_WB_WriteRegister  %d , MEM_WB_ALUResult  %d , MEM_WB_ReadData  %d", nMemtoReg, nRegWrite, nWriteRegister, nALUResult, nReadData);
        nALUResult<=cALUResult;
        nReadData<=cReadData;
        nWriteRegister<=cWriteRegister;
        nMemtoReg<=cMemtoReg;
        nRegWrite<=cRegWrite;
    end

endmodule

/////////////////////////BONUS////////////////////////////////////////////////

module HazardUnit(HazardOutput,clk,EXMemread,EXRT,IFRT,IFRS);
output reg HazardOutput;
input clk;
input[1:0] EXMemread;
input[4:0]EXRT,IFRT,IFRS;


always@(EXMemread,EXRT,IFRT,IFRS)
    begin
    if((EXMemread!=0) && ( (EXRT==IFRS) || (EXRT == IFRT) ))
        HazardOutput <= 0;
      else 
        HazardOutput <= 1;
    end

endmodule

module muxEXHazard(RegDst,Branch,MemRead,MemtoReg,MemWrite,ALUSrc
,RegWrite,Hazard,RegDstOut,BranchOut,MemReadOut,MemtoRegOut,MemWriteOut,ALUSrcOut,RegWriteOut);
   
    input RegDst,Branch,MemtoReg,MemWrite,ALUSrc,RegWrite,Hazard;
    input[1:0] MemRead;
   
    output reg RegDstOut,BranchOut,MemtoRegOut,MemWriteOut,ALUSrcOut,RegWriteOut;
    output reg [1:0] MemReadOut;
   
   
    always@(RegDst,Branch,MemRead,MemtoReg,MemWrite,ALUSrc,RegWrite,Hazard)
    begin
        if(Hazard == 0)
        begin
            RegDstOut <= 0;
            BranchOut <= 0;
            MemReadOut<= 0;
            MemtoRegOut<=0;
            MemWriteOut<=0;
            ALUSrcOut  <=0;
            RegWriteOut<=0;        
        end
        else
        begin
            RegDstOut <= RegDst;
            BranchOut <= Branch;
            MemReadOut<= MemRead;
            MemtoRegOut<= MemtoReg;
            MemWriteOut<= MemWrite;
            ALUSrcOut  <= ALUSrc;
            RegWriteOut<= RegWrite; 
        end
    end
endmodule


module ForwardingUnit (ForwardA,ForwardB,clk,MemRegWrite,MemRD,WBRegWrite,WBRD,EXRS,EXRT);
   input clk,MemRegWrite,WBRegWrite;
   input[4:0]WBRD,EXRS,EXRT,MemRD;
   output reg[1:0] ForwardA,ForwardB;
   
  
   
   always@(MemRegWrite,MemRD,WBRegWrite,WBRD,EXRS,EXRT)
   begin
   //$display("ForWardA ",ForwardA);
   if(MemRegWrite ==1 && (MemRD !=0) && (MemRD ==EXRS))
   ForwardA <= 2'b10;
   else if(WBRegWrite ==1 && (WBRD !=0) && (WBRD ==EXRS) &&  ((MemRegWrite ==1 && (MemRD !=0) && (MemRD ==EXRS)) !=1))
   ForwardA <= 2'b01;
   else ForwardA  <= 2'b00;
   
   if(MemRegWrite ==1 && (MemRD !=0) && (MemRD ==EXRT))
   ForwardB <= 2'b10;
   else  if(WBRegWrite ==1 && (WBRD !=0) && (WBRD ==EXRT) && (MemRegWrite ==1 && (MemRD !=0) && (MemRD ==EXRT))!=1)
   ForwardB <= 2'b01;
   else ForwardB <= 2'b00;
   
   end
endmodule

module ALUForwardMux (ALUin,RSOriginal,EXRS,MEMRS,Forward);
input [31:0] EXRS,MEMRS,RSOriginal;
input [1:0] Forward;
output reg [31:0] ALUin;

always @ (RSOriginal,EXRS,MEMRS,Forward) begin
   if(Forward == 2'b01)
   ALUin <= MEMRS;
    else if(Forward == 2'b10)
    ALUin <= EXRS;
    else
     ALUin <= RSOriginal;

end

endmodule

////////////////////////////////////////////////////////////////////////////
 
module datapath(Answer,clk);
output   [31:0] Answer;
reg [31:0] pc;
wire [31:0] pc2,Newpc;
input clk;
wire [31:0] instruction,readData1,readData2,writeData,SignExtensionout,ALUin2, ALUResultBranch, readData; // ALU ResultBranch may be signed (not sure)
wire signed [31:0] ALUOut;
wire RegDst,Branch,MemtoReg,MemWrite,ALUSrc,RegWrite, zeroflag,isBranch;
wire [4:0] writeRegister;
wire [1:0] MemRead;
wire [3:0] ALUOp;

/// EX ///
wire [31:0] EXSignExtend, EXReadData1, EXReadData2, EXPC;
wire [4:0] EXRt, EXRd, EXShamt;
wire [5:0] EXOp, EXFunc;
wire EXRegDst,EXBranch,EXMemtoReg,EXMemWrite,EXALUSrc,EXRegWrite;
wire [1:0] EXMemRead;


// MEM ///

wire[31:0] MEMWriteData, MEMPC, MEMALUResult;
wire[4:0] MEMWriteRegister; 
wire MEMRegWrite, MEMMemtoReg, MEMMemWrite, MEMBranch, MEMZeroFlag;
wire [1:0] MEMMemRead;


// WB ///


wire WBMemtoReg, WBRegWrite; 
wire [4:0] WBwriteRegister; 
wire [31:0] WBALUResult, WBReadData;


// DECODE ///

wire [31:0] newInstruction, newPC;


////bonus////
wire HazardOutput, RegDstOut,BranchOut,MemtoRegOut,MemWriteOut,ALUSrcOut,RegWriteOut;
wire [1:0] MemReadOut,ForwardA,ForwardB;
wire [4:0] EXRS;
wire [31:0] ALURS,ALURT;


//assign pc=0;
always @(posedge clk) begin
//$display ("instruction %b pc %b clk %b",instruction,pc,clk);
//$display ("regdest %b, branch %b, memread %b, memtoreg %b, memwrite %b, alusrc %b, regwrite %b",RegDst,Branch,MemRead,MemtoReg,MemWrite,ALUSrc,RegWrite);
//$display("writeRegister %b",writeRegister);
//$display("writeData %b, regWrite %b, readData1 %b, readData2 %b, Answer %b",writeData , RegWrite , readData1 , readData2 , Answer);
//$display("ALUOp %b", ALUOp);
//$display("ALUOut %b,zeroflag %b", ALUOut,zeroflag);
//$display("readData2 %b, SignExtensionout %b, ALUSrc %b, ALUin2 %b",readData2, SignExtensionout, ALUSrc, ALUin2);
end

initial begin
#0 pc = 0;
end


InstructionMemory im (instruction,pc,clk);
 
//Adder addBy4 (NEWESTPC,Newpc,clk); //assign pc = Newpc;
assign Newpc=pc+4;
always@(posedge clk)
begin
if(HazardOutput ==0)
    pc<= pc;
else
    begin
    if(MEMBranch&&MEMZeroFlag)
        pc <= MEMPC;
    else
        pc <= Newpc;
    end
end
///////////\/\/\/\/\/\/\/\/
 
/////////////////////////////////bonus/////////////////////////////

HazardUnit HU  (HazardOutput,clk,EXMemRead,EXRt,newInstruction[20:16],newInstruction[25:21]);

ForwardingUnit FU (ForwardA,ForwardB,clk,MEMRegWrite,MEMWriteRegister,WBRegWrite,WBwriteRegister
,EXRS,EXRt);

//////////////////////////////////////////////////////////////////


IF_ID if_id(HazardOutput,instruction, Newpc, clk, newInstruction, newPC);

controller control (newInstruction[31:26],RegDst,Branch,MemRead,MemtoReg,MemWrite,ALUSrc,RegWrite);
 
 muxEXHazard muxEXhazard(RegDst,Branch,MemRead,MemtoReg,MemWrite,ALUSrc
,RegWrite,HazardOutput,RegDstOut,BranchOut,MemReadOut,MemtoRegOut,MemWriteOut,ALUSrcOut,RegWriteOut);
 
Mux5 mux5 (EXRt, EXRd, EXRegDst, writeRegister); // hayegi tani
 
registerFile regs (clk , newInstruction[25:21] ,newInstruction[20:16] , 
WBwriteRegister, writeData , WBRegWrite , readData1 , readData2 , Answer);
 
signExtension signExtension1 (SignExtensionout, newInstruction[15:0]);



ID_EX id_ex(SignExtensionout, readData1, readData2, newPC, newInstruction[25:21],newInstruction[20:16], newInstruction[15:11], newInstruction[10:6], newInstruction[31:26], 
newInstruction[5:0],RegDstOut,BranchOut,MemReadOut,MemtoRegOut,MemWriteOut,ALUSrcOut,RegWriteOut, clk, 
EXSignExtend, EXReadData1, EXReadData2, EXPC,EXRS, EXRt, EXRd, EXShamt, EXOp, EXFunc,
EXRegDst,EXBranch,EXMemRead,EXMemtoReg,EXMemWrite,EXALUSrc,EXRegWrite);

ALUForwardMux mux1 (ALURS,EXReadData1,MEMALUResult,writeData,ForwardA);

Mux32 mux32 (EXReadData2, EXSignExtend, EXALUSrc, ALUin2);

ALUForwardMux mux2 (ALURT,ALUin2,MEMALUResult,writeData,ForwardB);
 
ALUcontrol aluControl(EXFunc,EXOp,ALUOp);
 
ALU alu  (ALURS,ALURT,EXShamt,ALUOp,ALUOut,zeroflag);

 //assign SignExtensionout2 = SignExtensionout*4; // here
 //assign isBranch = Branch&zeroflag;
 
BranchAdder branchadder(ALUResultBranch,EXPC,EXSignExtend*4); // not sure if multiplying by 4 works or not
 

 
 EX_MEM ex_mem(clk, EXReadData2, ALUResultBranch, writeRegister, EXRegWrite, EXMemtoReg, ALUOut,
 EXMemWrite, EXMemRead, EXBranch, zeroflag, 
MEMWriteData, MEMPC, MEMWriteRegister, MEMRegWrite, MEMMemtoReg, MEMALUResult,
MEMMemWrite, MEMMemRead, MEMBranch, MEMZeroFlag);
 
//Mux32 ZeroFlagAndBranch(Newpc, ALUResultBranch, Branch&zeroflag ,  pc2); 

//assign pc = pc2;
//pcCounter pcc (pc2 , clk , NEWESTPC); helooolloololo
 
DataMemory dataMemory(MEMALUResult,MEMWriteData,MEMMemWrite,clk,MEMMemRead,readData);


MEM_WB mem_wb(MEMMemtoReg, MEMRegWrite, MEMWriteRegister, MEMALUResult, readData, clk,
WBMemtoReg, WBRegWrite, WBwriteRegister, WBALUResult, WBReadData);
 
Mux32 mux32Writedata (WBALUResult, WBReadData, WBMemtoReg,  writeData);

endmodule

module test();
reg clk;
wire[31:0] out;
datapath dp(out,clk);
always @ (posedge clk) begin
$display ("out %b",out );

end
initial 
begin
clk =0;
forever begin
#5 clk=~clk;
//#30000 $finish;
end
end

endmodule

