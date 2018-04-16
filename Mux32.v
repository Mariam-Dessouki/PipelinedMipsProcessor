module Mux32(in1, in2, switch,  out);
output reg [31:0] out;
input [31:0] in1, in2;
input switch;

always@(switch)
	begin
		case(switch)
		0: out=in1;
		1: out=in2;
		endcase
	end


endmodule 