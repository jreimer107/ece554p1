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

	reg [7:0] db_high;
	reg [7:0] db_low;
	reg [8:0] txbuf;
	reg [7:0] rxbuf;
	reg [7:0] status;
	reg [15:0] down_count;
	reg [3:0] enable_count;

	reg [3:0] tx_cnt;
	assign tbr = tx_cnt == 0;

	assign write_databus = iorw == 0;
	assign txd = txbuf[0];
	assign rda = 1;
	
	//reg enable;
	always @(posedge clk, posedge rst) begin
		//enable <= 0;
		if (rst) begin
			txbuf <= 9'h1ff;
			rxbuf <= 8'h21;
			tx_cnt <= 4'hf;
			enable_count <= 4'hf;
			db_high <= 8'h01;
			db_low <= 8'h44;
			down_count <= 16'h0144;
		end
		else begin
			if (ioaddr == 2'b10) begin
				down_count <= {db_high, databus};
				enable_count <= 4'hf;
			end
			else if (down_count != 0) begin
				down_count <= down_count - 1;
			end
			else begin
				down_count <= {db_high, db_low};
				if (enable_count != 0) begin
					enable_count <= enable_count - 1;
				end
				else begin
					enable_count <= 4'hf;
					txbuf <= {1'b1, txbuf[8:1]};
					tx_cnt <= tx_cnt == 0 ? 0 : tx_cnt - 1;
				end
			end
		
			case (ioaddr)
				2'b00: begin
					if (iorw == 1'b0) begin
						txbuf <= {rxbuf, 1'b0};
						tx_cnt <= 11;
					end 
					else begin
						// write_databus = 1'b1;
					end
				end
				2'b01: begin
					if (iorw == 1'b1) begin
						status = databus;
					end
				end
				2'b10: begin
					db_low <= databus;
				end
				2'b11: begin
					db_high <= databus;
				end
			endcase
		end
	end
 
	assign databus = write_databus & ~iocs ? rxbuf : 8'hzz;

endmodule
