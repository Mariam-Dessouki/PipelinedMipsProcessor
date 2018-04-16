module Adder(in, out);
output reg [31:0] out;
input [31:0] in;

always@(in)
	begin
		out=in+4;
	end
endmodule 