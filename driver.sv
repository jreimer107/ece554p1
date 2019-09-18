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
    output reg iorw,
    input rda,
    input tbr,
    output reg [1:0] ioaddr,
    inout [7:0] databus
    );

	reg [1:0] br_cfg_old;
	reg [15:0] br;
	reg [7:0] databus_staging;
	reg [1:0] br_load_cnt;
	
	typedef enum reg [1:0] {INIT, LD_BR_HI, LD_BR_LO, NORMAL} state_t;
	state_t state, nxt_state;
	
	//State ff
	always_ff @(posedge clk, negedge rst) begin
		if (!rst) state <= INIT;
		else state <= nxt_state;
	end
	
	//BR_old ff
	always_ff @(posedge clk, negedge rst) begin
		br_cfg_old <= br_cfg;
	end
	
	reg write_databus;
	always_comb begin
		nxt_state = INIT;
		write_databus = 0;
		iorw = 1;
		
		//Determine br from br_cfg
		case (br_cfg)
			2'b00:
				br = 4800;
				
			2'b01:
				br = 9600;
				
			2'b10:
				br = 19200;

			2'b11:
				br = 38400;

		endcase
	
		case(state)
			INIT: begin
				nxt_state = NORMAL;
			end
			
			LD_BR_HI: begin
				databus_staging = br[15:8];
				ioaddr = 2;
				write_databus = 1;
				nxt_state = LD_BR_LO;
			end
			
			LD_BR_LO: begin
				databus_staging = br[7:0];
				ioaddr = 3;
				write_databus = 1;
				nxt_state = NORMAL;
			end
			
			NORMAL: begin
				ioaddr = 1;
				if (br_cfg != br_cfg_old)
					nxt_state = LD_BR_HI;
				else nxt_state = NORMAL;
			end
			
		endcase
	end

	

/* 	always@ (posedge clk, negedge rst) begin
		ioaddr = 2'b00;
		iorw = 1'b1;
		if (tbr == 1) begin
			iorw = 1'b0;
		end
		else if (rda == 1) begin
			iorw = 1'b1;
		end

		if (!rst || br_cfg != br_cfg_old) begin
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
			br_load_cnt <= 3;
			br_cfg_old = br_cfg;
		end
		
		if (br_load_cnt == 3) begin
			br_staging <= br[7:0];
			ioaddr <= 2;
			br_load_cnt <= 2;
		end
		else if (br_load_cnt == 2) begin
			br_staging <= br[15:8];
			ioaddr <= 3;
			br_load_cnt <= 1;
		end
		else if (br_load_cnt == 1) begin
			br_load_cnt <= 0;
		end

	end */

	assign databus = write_databus ? databus_staging : 8'bz;

endmodule
