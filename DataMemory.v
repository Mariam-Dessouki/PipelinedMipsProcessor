module DataMemory(address,writeData,memWrite,clk,memRead,readData);
input [31:0] address,writeData;
input memWrite;
input[1:0] memRead;
input clk;
output reg [31:0] readData;
reg[7:0] dMem[1023:0];
always@(posedge clk)
	begin
	if(memWrite)//sw
		dMem[address]= writeData[31:24];
		dMem[address+1]= writeData[23:16];
		dMem[address+2]= writeData[15:8];
		dMem[address+3]= writeData[7:0];
	end
always@(address,writeData,memRead)
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
				begin
				readData = {16'b1111111111111111,dMem[address],dMem[address+1]};
			        
				end
			else
				begin
				readData = {16'b0000000000000000,dMem[address],dMem[address+1]};	
				end
		end
		else if(memRead==3)//lhu
		begin
		    readData = {16'b0000000000000000,dMem[address],dMem[address+1]};
		end
		
	end

endmodule 
