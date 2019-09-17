module spart_tb();

reg [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
wire [3:0] KEY;
wire [9:0] LEDR;
wire [9:0] SW;
wire [35:0] GPIO;
wire clk;

assign KEY = 4'hf;
assign LEDR = 9'h080;

lab1_spart DUT(.CLOCK_50);

always
	#10 clk = ~clk;

endmodule