`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:20:49 02/28/2015 
// Design Name: 
// Module Name:    lab4 
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
module lab4(gclk,rd,addr,we,mem_data,rst,valid,mem_addr,data);
	
	input gclk;
	input rd,we;
	input [31:0] addr,mem_data;
	
	output rst,valid;
	output [31:0] mem_addr,data;
	 
	
	wire clk_in,clk;
	IBUFG gclkin_buf (.O(clk_in), .I(gclk));

	DCM_SP clk_divider (.CLKFB(feedback_clk2),
					.CLKIN(clk_in),
					.CLKDV(divided_clk),
					.CLK0(feedback_clk),
					.PSEN(1'b0),
					.LOCKED(locked_int),
					.RST(1'b0));

	defparam clk_divider.CLKDV_DIVIDE = 2.0; 
	defparam clk_divider.CLKIN_PERIOD = 10.0;
	defparam clk_divider.CLK_FEEDBACK = "1X";
	defparam clk_divider.CLKIN_DIVIDE_BY_2 = "FALSE";
	defparam clk_divider.CLKOUT_PHASE_SHIFT = "NONE";
	defparam clk_divider.DESKEW_ADJUST = "SYSTEM_SYNCHRONOUS";
	defparam clk_divider.DFS_FREQUENCY_MODE = "LOW";
	defparam clk_divider.DLL_FREQUENCY_MODE = "LOW";
	defparam clk_divider.DSS_MODE = "NONE";
	defparam clk_divider.DUTY_CYCLE_CORRECTION = "TRUE";

	BUFG feedback_BUFG(.I(feedback_clk),.O(feedback_clk2));
	BUFG out_BUFG (.I(divided_clk), .O(clk));
	
	
	
	cache NU(clk,rst,we,mem_data,mem_addr,rd,addr,valid,data); // the inputs needs to havel


endmodule

//module cache(clk,rst,we,mem_data,mem_addr,rd,addr,valid,data,reg_addr,hit,miss,way,state);
  module cache(clk,rst,we,mem_data,mem_addr,rd,addr,valid,data);
	input clk;
	input rst;
	
	input we;
	input [31:0] mem_data;
	output [31:0] mem_addr;
	
	input rd;
	input [31:0] addr;
	output valid;
	output [31:0] data;
	output [31:0] reg_addr;
	output hit,miss;
	output [2:0] way;
	output [4:0] state;
   wire [31:0] reg_addr;
	wire hit,miss;
	wire [2:0] way;
	wire [5:0] state;
	
	blockW B(clk,rd,addr,we,mem_data,rst,mem_addr,reg_addr,hit,miss,data,way,state);
		
endmodule


module blockW(clk,
				 rd,
				 addr,
				 we,
				 mem_data,
				 rst,
				 mem_addr,
				 reg_addr,
				 hit,
				 miss,
				 datac,
				 way,
				 state
    );
	 
	 input clk;
	 input rd; 				   // from cpu
	 input [31:0] addr;     // from cpu
	 input [31:0] mem_data; // from main memory
	 input we;
	 input rst; 				// user
	 output reg [31:0] mem_addr;// to main memory
	 output reg [31:0] datac;
	 
	 
	output reg [31:0] reg_addr; 
	output reg hit,miss;
	output reg [2:0] way;
	output [5:0] state;
	
	
	reg [23:0] tag,tag_check;
	
	 
	 reg [63:0] way1[0:1023];
    //synthesis attribute ram_style of way1 is block	 
	 reg [63:0] way2[0:1023];
    //synthesis attribute ram_style of way2 is block	 
	 reg [63:0] way3[0:1023];
	 //synthesis attribute ram_style of way3 is block
	 reg [63:0] way4[0:1023]; 
	 //synthesis attribute ram_style of way4 is block
	 
	 //initialize cache to test
	 integer i;
	 initial begin
		way = 3'b000;
		for(i=0;i<1023;i=i+1)begin
			if(i%2 == 0)begin
				way1[i] <= 64'h3CC_CCCC_CCCC_CCAA;
				way2[i] <= 64'h2DD_DDDD_DDDD_DDAA;
				way3[i] <= 64'h1EE_EEEE_EEEE_EEAA;
				way4[i] <= 64'h0FF_FFFF_FFFF_FFFF;
			end
			else begin
				way1[i] <= 64'h300_0000_0000_ABCD;
				way2[i] <= 64'h200_0000_0000_ABCD;
				way3[i] <= 64'h100_0100_0000_ABCD;
				way4[i] <= 64'h000_1000_0000_ABCD;
			end
		end
	 end
	 
	 
	 
	 SM cacheM(clk,rd,hit,miss,we,rst,state);
	 
	 
	 //stores addr & tag from cpu
	 always @(posedge clk)begin
		if(rd)
			reg_addr <= addr;
			tag <= reg_addr[31:8]; //tag is last 24 bits of addr
	 end
	 
	 //check cache for a match
	 //comparator
	 always @(posedge clk)begin
		 if(way == 3'b001 && state[1]) //way1
			tag_check <= way1[reg_addr[7:0]][55:32];
		 else if(way == 3'b010 && state[1])//way2
			tag_check <= way2[reg_addr[7:0]][55:32];
		 else if(way == 3'b011 && state[1])//way3
			tag_check <= way3[reg_addr[7:0]][55:32];
		 else if(way == 3'b100 && state[1])//way4
			tag_check <= way4[reg_addr[7:0]][55:32];
		 else
			tag_check <= 15;
	 end
	 
	
	 
	 //check's if hit or miss in all of set N
	 always @(posedge clk)begin
		if(tag_check == tag && state[1] && ~hit)begin
			hit <= 1'b1;
			//way <= 3'b000;
			miss <= 1'b0;
		end
		else if(way <= 3'b100 && state[1])begin
			hit <= 1'b0;
			way <= way + 1'b1;
			miss <=1'b0;
		end
		else if(way >= 3'b101 && state[1] && ~hit)begin
			way <= 3'b000;
			miss <= 1'b1;
		end
		else hit <= 1'b0;
		if(state[4])way <= 3'b000; //resets way when data ready
			
	end
	
	always @(posedge clk) begin
		if(miss) mem_addr <= reg_addr;
	end

	//need to return cache data on hit
	always @(posedge clk) begin
		if(hit && way == 3'b010) datac <= way1[reg_addr[7:0]][31:0];
		else if(hit && way == 3'b011) datac <= way2[reg_addr[7:0]][31:0];
		else if(hit && way == 3'b100) datac <= way3[reg_addr[7:0]][31:0];
		else if(hit && way == 3'b101) datac <= way4[reg_addr[7:0]][31:0];
		else if(we && state[2]) datac <= mem_data;
	end
	
	reg [1:0] lru1,lru2,lru3,lru4;
	
	
	//maximizing notes try doing all logiv outsie then only assign inside on
	//ie
	//temp1=reg_addr[7:0]
	//temp2 = {{1'b1,5'b0_0000,lru1,mem_data[31:8],mem_data}
	
	//following in own block
	//way1[temp1] =<  temp2
	
	//test LRU
	always @(posedge clk) begin
		if(we && state[2])begin //if goes to memory
			if(lru1 == 2'b11)begin
				way1[reg_addr[7:0]] <= {1'b1,5'b0_0000,lru1,mem_data[31:8],mem_data};//need to update lru
			end
		
			else if(lru2 == 2'b11)begin
				way2[reg_addr[7:0]] <= {1'b1,5'b0_0000,lru2,mem_data[31:8],mem_data};//need to update lru
			end
			else if(lru3 == 2'b11)begin
				way3[reg_addr[7:0]] <= {1'b1,5'b0_0000,lru3,mem_data[31:8],mem_data};//need to update lru
			end
			else if(lru4 == 2'b11)begin
				way4[reg_addr[7:0]] <= {1'b1,5'b0_0000,lru4,mem_data[31:8],mem_data};
			end
		end
	end//end of initial LRU
	
	
	//reg [1:0] lru1,lru2,lru3,lru4;
	//LRU control algorithmn -- updates last used
	always @(posedge clk) begin
		if(state[3])begin
			lru1 <= lru1 +1'b1;
			lru2 <= lru2 +1'b1; 
			lru3 <= lru3 +1'b1; 
			lru4 <= lru4 +1'b1; 			
		end
	end
	
endmodule // end of blockW

