//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    
// Design Name: 
// Module Name:    driver 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module driver(
    input clk,
    input rst,
    input [1:0] br_cfg,
    output iocs,
    output iorw,
    input rda,
    input tbr,
    output reg [1:0] ioaddr,
    inout [7:0] databus
    );

	reg [1:0] br_cfg_old;
	reg [15:0] br;
	reg [7:0] br_staging;
	reg [1:0] br_load_cnt;

	always@ (posedge clk) begin
		ioaddr = 2'b00;
		if (tbr == 1) begin
			iorw = 1'b0;
		end
		else if (rda == 1) begin
			iorw = 1'b1;
		end

		if (br_cfg != br_cfg_old) begin
			case (br_cfg)
				2'b00: begin
					br = 4800;
				end
				2'b01: begin
					br = 9600;
				end
				2'b10: begin
					br = 19200;
				end
				2'b11: begin
					br = 38400;
				end
			endcase
			br_staging = br[7:0];
			ioaddr = 2;
			br_load_cnt = 2;
			br_cfg_old = br_cfg;
		end

		if (br_load_cnt == 2) begin
			br_staging = br[15:8];
			ioaddr = 3;
			br_load_cnt = 1;
		end
		else if (br_load_cnt == 1) begin
			br_load_cnt = 0;
		end

	end

	assign databus = br_load_cnt != 2'b00 ? br_staging : 8'bz;

endmodule
