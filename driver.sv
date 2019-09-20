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
    output reg iocs,
    output reg iorw,
    input rda,
    input tbr,
    output reg [1:0] ioaddr,
    inout [7:0] databus
    );

	reg [1:0] br_cfg_old;
	reg [15:0] br;
	reg [7:0] store;
	reg [7:0] nxt_store;
	
	typedef enum reg [2:0] {INIT, LD_BR_HI, LD_BR_LO, SND_BR_LO, NORMAL} state_t;
	state_t state, nxt_state;
	
	//State ff
	always_ff @(posedge clk, posedge rst) begin
		if (rst) state <= INIT;
		else state <= nxt_state;
	end
	
	//BR_old ff
	always_ff @(posedge clk, posedge rst) begin
		if (rst) begin
			br_cfg_old <= 2'b01;
			store <= 8'hff;
		end
		else begin
			br_cfg_old <= br_cfg;
			store <= nxt_store;
		end
	end
	
	always_comb begin
		nxt_state = INIT;
		nxt_store = store;
		ioaddr = 1;
		iocs = 0;
		iorw = 1;
		
		//Determine br from br_cfg
		case (br_cfg)
			2'b00:
				br = 16'h028a;
				
			2'b01:
				br = 16'h0144;
				
			2'b10:
				br = 16'h00a1;

			2'b11:
				br = 16'h0050;

		endcase
	
		case(state)
			INIT: begin
				nxt_state = NORMAL;
			end
			
			LD_BR_HI: begin
				nxt_store = br[15:8];
				nxt_state = LD_BR_LO;
			end
			
			LD_BR_LO: begin
				nxt_store = br[7:0];
				ioaddr = 3;
				iocs = 1;
				nxt_state = SND_BR_LO;
			end
			
			SND_BR_LO: begin
				ioaddr = 2;
				iocs = 1;
				nxt_state = NORMAL;
				nxt_store = 8'hff;
			end
			
			NORMAL: begin
				ioaddr = 0;
				if (br_cfg != br_cfg_old)
					nxt_state = LD_BR_HI;
				else nxt_state = NORMAL;
				
				if (rda) begin
					iorw = 1;
					nxt_store = databus;
				end

				if (tbr && store != 8'hff) begin
					iorw = 0;
					iocs = 1;
					nxt_store = 8'hff;
				end
			end
			
		endcase
	end


	assign databus = iocs ? store : 8'bz;

endmodule
