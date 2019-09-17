//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:   
// Design Name: 
// Module Name:    spart 
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
module spart(
    input clk,
    input rst,
    input iocs,
    input iorw,
    output rda,
    output tbr,
    input [1:0] ioaddr,
    inout [7:0] databus,
    output reg txd,
    input rxd
    );

	wire spart_reg;
	wire enable;

	reg [7:0] db_high;
	reg [7:0] db_low;
	reg [8:0] txbuf;
	reg [7:0] rxbuf;
	reg [7:0] status;
	reg [15:0] down_count;
	wire down_amount;

	reg enable_reg;
	reg [3:0] tx_cnt;
	assign tbr = tx_cnt == 0;

	reg transmit;

	always@ (posedge clk, posedge rst) begin
		if (rst) begin
			txbuf <= 9'h1ff;
			rxbuf <= 8'h21;
			tx_cnt <= 4'h0;
		end

		transmit = 1'b0;
		case (ioaddr)
			2'b00: begin
				if (iorw == 1'b0) begin
					txbuf = {databus, 1'b0};
					tx_cnt = 10;
				end 
				else begin
					transmit = 1'b1;
				end
			end
			2'b01: begin
				if (iorw == 1'b1) begin
					status = databus;
				end
			end
			2'b10: begin
				db_low = databus;
			end
			2'b11: begin
				db_high = databus;
			end
		endcase
	
		if (enable == 1 && enable_reg == 0) begin
			down_count = {db_high, db_low};
			txd = txbuf[0];
			txbuf = {1'b1, txbuf[8:1]};
			tx_cnt = tx_cnt == 0 ? 0 : tx_cnt - 1;
		end
		else begin
			down_count  = down_count < down_amount ? 0 : down_count - down_amount;
		end

		enable_reg = enable;
	end

	assign down_amount = 50000000 / ({db_high, db_low} << 4) - 1;
	assign enable = down_count == 16'b0;
 
	assign databus = transmit ? rxbuf : 8'hzz;

	// always@ (posedge enable) begin
	// 	down_count = {db_high, db_low};
	// 	txd = txbuf[0];
	// 	txbuf = {1'b1, txbuf[8:1]};
	// 	tx_cnt = tx_cnt == 0 ? 0 : tx_cnt - 1;
	// end

endmodule
