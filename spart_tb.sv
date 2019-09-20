module spart_tb();

reg [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
wire [3:0] KEY;
wire [9:0] LEDR;
reg [9:0] SW;
wire [35:0] GPIO;
reg clk;
reg rst;

reg rxd;
assign GPIO[5] = rxd;

assign KEY = {3'b111, rst};

lab1_spart DUT(.CLOCK_50(clk), .CLOCK2_50(clk), .CLOCK3_50(clk), .CLOCK4_50(clk),
	.HEX0(HEX0), .HEX1(HEX1), .HEX2(HEX2), .HEX3(HEX3), .HEX4(HEX4), .HEX5(HEX5),
	.KEY(KEY), .LEDR(LEDR), .SW(SW), .GPIO(GPIO));

initial begin
	clk = 0;
	rst = 0;
	SW = 10'h100;
	rxd = 1;
	repeat(2) @(negedge clk)
	rst = 1;
	rxd = 1;
	#100
	SW = 10'h300;
	#500000
	#51840
	rxd = 0;
	#51840
	rxd = 0;
	#51840
	rxd = 0;
	#51840
	rxd = 1;
	#51840
	rxd = 0;
	#51840
	rxd = 0;
	#51840
	rxd = 0;
	#51840
	rxd = 0;
	#51840
	rxd = 1;
	#51840
	rxd = 1;
end

always
	#10 clk = ~clk;

endmodule