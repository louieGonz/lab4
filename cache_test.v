`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    01:18:38 02/28/2015 
// Design Name: 
// Module Name:    cache_test 
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
module cache_test(clk,rst,we,mem_data,mem_addr,rd,addr,valid,data,hit,miss,way,tag,tag_check,lru1,lru2,lru3,lru4,state);
	input clk;
	input rst;
	
	input we;
	input [31:0] mem_data;
	output [31:0] mem_addr;
	
	input rd;
	input [31:0] addr;
	output valid;
	output [31:0] data;
	//output [31:0] reg_addr;
	output hit,miss;
	output [2:0] way;
	output [5:0] state;
	output [23:0] tag,tag_check;
	output [1:0] lru1,lru2,lru3,lru4;
	
	blockb B(clk,rd,addr,we,mem_data,rst,mem_addr,hit,miss,data,way,tag,tag_check,lru1,lru2,lru3,lru4,state);
		
endmodule


module blockb(clk,
				 rd,
				 addr,
				 we,
				 mem_data,
				 rst,
				 mem_addr,
				 
				 hit,
				 miss,
				 datac,
				 way,
				 tag,
				 tag_check,
				 lru1,
				 lru2,
				 lru3,
				 lru4,
				 
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
	 
	 
	//output reg [31:0] reg_addr; 
	output reg hit,miss;
	output reg [2:0] way;
	output reg [1:0] lru1,lru2,lru3,lru4;
	output [5:0] state;
	reg [31:0] reg_addr; 
	
	
	output reg [23:0] tag,tag_check;
	
	reg [256:0] way1[0:1023];
	//synthesis attribute ram_style of way1 is block
   reg [256:0] way2[0:1023];
	//synthesis attribute ram_style of way2 is block
   reg [256:0] way3[0:1023];
	//synthesis attribute ram_style of way3 is block	
	reg [256:0] way4[0:1023]; 
	//synthesis attribute ram_style of way4 is block
	
	 //initialize cache to test
	 integer i;
	 initial begin
		lru1=2'b11;
		lru2=2'b10;
		lru3=2'b01;
		lru4=2'b00;
		way = 3'b000;
		
		
		$readmemh("mMemory.txt",way1);
		$readmemh("mMemory2.txt",way2);
		$readmemh("mMemory3.txt",way3);
		$readmemh("mMemory4.txt",way4);
		
//		for(i=0;i<1024;i=i+1)begin
//			if(i%2 == 0)begin
//				way1[i] <= 64'h03CC_CCCC_CCCC_CCAA;
//				way2[i] <= 64'h02DD_DDDD_DDDD_DDAA;
//				way3[i] <= 64'h01EE_EEEE_EEEE_EEAA;
//				way4[i] <= 64'h00FF_FFFF_FFFF_FFFF;
//			end
//			else begin
//				way1[i] <= 64'h0300_0000_0000_ABCD;
//				way2[i] <= 64'h0200_0000_0000_ABCD;
//				way3[i] <= 64'h0100_0100_0000_ABCD;
//				way4[i] <= 64'h0000_1000_0000_ABCD;
//			end
//		end
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
	
//	always @(posedge clk)begin
//		if(we) datac <= mem_data;
//	end
	
	
	
	//need to return cache data on hit
	always @(posedge clk) begin
		if(hit && way == 3'b010) datac <= way1[reg_addr[7:0]][31:0];
		else if(hit && way == 3'b011) datac <= way2[reg_addr[7:0]][31:0];
		else if(hit && way == 3'b100) datac <= way3[reg_addr[7:0]][31:0];
		else if(hit && way == 3'b101) datac <= way4[reg_addr[7:0]][31:0];
		else if(we && state[2]) datac <= mem_data;
	end
	
	reg [1:0] written;
	
	//test LRU
	always @(posedge clk) begin
		if(we && state[2])begin //if goes to memory
			if(lru1 == 2'b11)begin
				way1[reg_addr[7:0]] <= {1'b1,5'b0_0000,lru1,mem_data[31:8],mem_data};//need to update lru
				//way1[reg_addr[7:0]][63] <= 1'b1; //sets valid bit
				//written <= 2'b00;
			end
		
			else if(lru2 == 2'b11)begin
				way2[reg_addr[7:0]] <= {1'b1,5'b0_0000,lru2,mem_data[31:8],mem_data};//need to update lru
				//written <= 2'b01;
			end
			else if(lru3 == 2'b11)begin
				way3[reg_addr[7:0]] <= {1'b1,5'b0_0000,lru3,mem_data[31:8],mem_data};//need to update lru
				//written <= 2'b10;
			end
			else if(lru4 == 2'b11)begin
				way4[reg_addr[7:0]] <= {1'b1,5'b0_0000,lru4,mem_data[31:8],mem_data};
				//written <= 2'b11;
			end
			//datac <= mem_data;
		
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
	
//	always @(posedge clk) begin
//		if(written == 2'b00 && state[3])begin
//			lru1 <= 2'b00;
//			lru2 <= way2[reg_addr[7:0]][57:56] + 1'b1;
//			lru3 <= way3[reg_addr[7:0]][57:56] + 1'b1;
//			lru4 <= way4[reg_addr[7:0]][57:56] + 1'b1;
//			
//		end
//		else if(written == 2'b01 && state[3])begin
//			lru1 <= way1[reg_addr[7:0]][57:56] + 1'b1;
//			lru2 <= 2'b00;
//			lru3 <= way3[reg_addr[7:0]][57:56] + 1'b1;
//			lru4 <= way4[reg_addr[7:0]][57:56] + 1'b1;
//			
//		end
//		else if(written == 2'b10 && state[3])begin
//			lru1 <= way1[reg_addr[7:0]][57:56] + 1'b1;
//			lru2 <= way2[reg_addr[7:0]][57:56] + 1'b1;
//			lru3 <= 2'b00;
//			lru4 <= way4[reg_addr[7:0]][57:56] + 1'b1;
//			
//		end
//		else if(written == 2'b11 && state[3] )begin
//			lru1 <= way1[reg_addr[7:0]][57:56] + 1'b1;
//			lru2 <= way2[reg_addr[7:0]][57:56] + 1'b1;
//			lru3 <= way3[reg_addr[7:0]][57:56] + 1'b1;
//			lru4 <= 2'b00;
//			
//		end
//	end
	
	
	

endmodule


