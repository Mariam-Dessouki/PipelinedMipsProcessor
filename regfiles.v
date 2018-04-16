module registerFile( clk , rs , rt , rd , writeData , regWrite , Data1 , Data2);
    input [4:0] rs ,rt , rd;
    input [31:0] writeData;
    input regWrite;
    input clk;
    output reg [31:0] Data1,Data2;
    reg[31:0] registers [31:0];
    always @(rs, rt)
    begin
        Data1 <= (rs==0)? 32'b0 : registers[rs];
        Data2 <= (rt==0)? 32'b0 : registers[rt];
    end
    always @ (posedge clk)
    begin 
    if(regWrite && rd!=0 )
        registers [rd] <= writeData;
    end
endmodule 