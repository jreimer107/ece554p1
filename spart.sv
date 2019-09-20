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
    output reg rda,
    output tbr,
    input [1:0] ioaddr,
    inout [7:0] databus,
    output reg txd,
    input rxd
    );


	reg [7:0] db_high, db_low;
	reg [8:0] txbuf;
	reg [8:0] rxbuf;
	reg [7:0] status;
	reg [15:0] down_count;
	reg [3:0] enable_count;

	reg [3:0] tx_cnt, rx_cnt;
	assign tbr = tx_cnt == 0;

	assign txd = txbuf[0];
	
	typedef enum reg [1:0] {START, READ, STOP} rx_state_t;
	rx_state_t rx_state, nxt_rx_state;
	
	always_ff @(posedge clk, posedge rst) begin
		if (rst) begin
			rx_state <= START;
		end
		else begin
			rx_state <= nxt_rx_state;
		end
	end
	
	always_comb begin
		nxt_rx_state = START;
		rda = 0;
		case(rx_state)
			START: begin
				if (rx_cnt == 9 && rxbuf[1] == 1 && rxbuf[0] == 0) begin
					nxt_rx_state = READ;
				end
			end
			
			READ: begin
				nxt_rx_state = rx_cnt == 0 ? STOP : READ;
			end
			
			STOP: begin
				if (rxbuf[0] != 1) begin
					nxt_rx_state = STOP;
				end
				else
					rda = 1;
			end
		endcase
	end
	
	always @(posedge clk, posedge rst) begin
		if (rst) begin
			txbuf <= 9'h1ff;
			rxbuf <= 9'h1ff;
			tx_cnt <= 4'hf;
			rx_cnt <= 9;
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
					if (enable_count == 8) begin
						rxbuf <= {rxbuf[7:0], rxd};
						if (rx_state == READ)
							rx_cnt <= rx_cnt == 0 ? 0 : rx_cnt - 1;
						else
							rx_cnt = 9;
					end
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
						txbuf <= {databus, 1'b0};
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
 
	assign databus = rda & ~iocs ? rxbuf[8:1] : 8'hzz;

endmodule
