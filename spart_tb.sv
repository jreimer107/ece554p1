module spart_tb();

reg [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
wire [3:0] KEY;
wire [9:0] LEDR;
wire [9:0] SW;
wire [35:0] GPIO;
reg clk;
reg rst;

assign KEY = {3'b111, rst};
assign SW = 10'h100;

lab1_spart DUT(.CLOCK_50(clk), .CLOCK2_50(clk), .CLOCK3_50(clk), .CLOCK4_50(clk),
	.HEX0(HEX0), .HEX1(HEX1), .HEX2(HEX2), .HEX3(HEX3), .HEX4(HEX4), .HEX5(HEX5),
	.KEY(KEY), .LEDR(LEDR), .SW(SW), .GPIO(GPIO));

initial begin
	clk = 0;
	rst = 1;
	repeat(2) @(negedge clk)
	rst = 0;
end

always
	#10 clk = ~clk;

endmodule