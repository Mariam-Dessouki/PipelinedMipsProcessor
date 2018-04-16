module BranchAdder(out,in1,in2);
output reg [31:0] out;
input [31:0] in1,in2;
always @(in1 , in2)
out = in1 + in2;

endmodule
