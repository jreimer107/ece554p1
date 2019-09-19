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
	reg [7:0] store;
	wire [7:0] nxt_store;
	reg [1:0] br_load_cnt;
	
	typedef enum reg [1:0] {INIT, LD_BR_HI, LD_BR_LO, NORMAL} state_t;
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
			store <= 0;
		end
		else begin
			br_cfg_old <= br_cfg;
			store <= nxt_store;
	end
	
	reg write_databus;
	always_comb begin
		nxt_state = INIT;
		databus_staging = 8'hff;
		ioaddr = 0;
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
				ioaddr = 3;
				write_databus = 1;
				nxt_state = LD_BR_LO;
			end
			
			LD_BR_LO: begin
				databus_staging = br[7:0];
				ioaddr = 2;
				write_databus = 1;
				nxt_state = NORMAL;
			end
			
			NORMAL: begin
				ioaddr = 1;
				if (br_cfg != br_cfg_old)
					nxt_state = LD_BR_HI;
				else nxt_state = NORMAL;
				
				if (rda) begin
					ioaddr = 0;
					iorw = 1;
					databus_staging = databus;
				end

				
				if (tbr && rda) begin
					ioaddr = 2'b00;
					iorw = 0;
				end
			end
			
		endcase
	end


	assign databus = write_databus ? databus_staging : 8'bz;

endmodule
