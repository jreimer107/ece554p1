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
	reg [15:0] down_count, nxt_down_count;

	reg [3:0] tx_cnt;
	assign tbr = tx_cnt == 0;

	assign transmit = iorw == 0;
	assign txd = txbuf[0];
	
	typedef enum reg [1:0] {INIT, WAIT, ENABLE, CHANGE} br_state_t;
	br_state_t br_state, nxt_br_state;
	
	always_ff @(posedge clk, negedge rst) begin
		if (!rst) begin
			br_state <= INIT;
			down_count = 50000000 / (9600 << 4) - 1;
		end
		else begin
			br_state <= nxt_br_state;
			down_count <= nxt_down_count;
		end
		
	end
	
	always_comb begin
		nxt_br_state = INIT;
		nxt_down_count = down_count;
		
		case(br_state)
			INIT: begin
				//db_high = 8'h25; //Initialize baud rate to 9600
				//db_low = 8'h80;
				nxt_br_state = WAIT;
			end
			
			CHANGE: begin
				nxt_down_count = 50000000 / ({db_high, db_low} << 4) - 1;
				nxt_br_state = WAIT;
			end
		
			WAIT: begin
				nxt_down_count = down_count - 1;
				if (down_count == 0)
					nxt_br_state = ENABLE;
				else if (ioaddr == 2'b11)
					nxt_br_state = CHANGE;
				else
					nxt_br_state = WAIT;
			end
			
			ENABLE: begin
				nxt_down_count = 50000000 / ({db_high, db_low} << 4) - 1;
				nxt_br_state = WAIT;
			end
		endcase
	end


	always @(posedge clk, negedge rst) begin
		if (!rst) begin
			txbuf <= 9'h1ff;
			rxbuf <= 8'hff;
			tx_cnt <= 4'hf;
		end
	end

	always@ (posedge clk, negedge rst) begin
		case (ioaddr)
			2'b00: begin
				if (iorw == 1'b0) begin
					txbuf = {databus, 1'b0};
					tx_cnt = 10;
				end 
				else begin
					// transmit = 1'b1;
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
	
		if (br_state == ENABLE) begin
			txbuf = {1'b1, txbuf[8:1]};
			tx_cnt = tx_cnt == 0 ? 0 : tx_cnt - 1;
		end
	end
 
	assign databus = transmit ? rxbuf : 8'hzz;

	// always@ (posedge enable) begin
	// 	down_count = {db_high, db_low};
	// 	txd = txbuf[0];
	// 	txbuf = {1'b1, txbuf[8:1]};
	// 	tx_cnt = tx_cnt == 0 ? 0 : tx_cnt - 1;
	// end

endmodule
