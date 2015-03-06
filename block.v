`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:21:05 02/24/2015 
// Design Name: 
// Module Name:    block 
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
module block(clk,
				 rd,
				 addr,
				 reg_addr,
				 tag,
				 tag_check,
				 way,
				 miss,
				 atMM,
				 state,
				 outMM,
				 way1set0,
				 way2set0,
				 way3set0,
				 way4set0,
				 way1data,
				 way2data,
				 way3data,
				 way4data,
				 hit
    );
	 
	 input clk;
	 input rd;
	 input [31:0] addr;
	 output reg hit,miss,atMM;
	 output reg [1:0] outMM;
	 output reg [1:0] way1set0,way2set0,way3set0,way4set0;
	 output reg [31:0] way1data,way2data,way3data,way4data;
	 
	 output reg [31:0] reg_addr;
	 output reg [23:0] tag,tag_check;
	 output reg [2:0] way;
	 
	 output [4:0] state;
	 
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
		for(i=0;i<1024;i=i+1)begin
			if(i%2 == 0)begin
				way1[i] <= 64'h300_0001_0001_AAAA;
				way2[i] <= 64'h200_00AB_0010_AAAA;
				way3[i] <= 64'h100_0100_0100_AAAA;
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
	 
	 
	 reg [4:0] state;
	 SM cacheM(clk,rd,hit,atMM,outMM,state);
	 
	 
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
	 //need to add state machine inputs all only happen when in state inCache
	 always @(posedge clk)begin
		if(tag_check == tag && state[1] && ~hit)begin
			hit <= 1'b1;
			way <= 3'b000;
			miss <= 1'b0;
		end
		else if(way <= 3'b100 && state[1])begin
			hit <= 1'b0;
			way <= way + 1'b1;
			miss <=1'b0;
		end
		else if(way == 3'b101 && state[1])begin
			way <= 3'b000;
			miss <= 1'b1;
		end
		if(state[3])way <= 3'b000; //resets way -- will need to configure with LRU i think
			
	end
	
	always @(posedge clk) begin
		if(miss) mem_addr <= reg_addr;
	end
	 
	 
	 //signal to show that going/in the MM
	 always @(posedge clk)begin
		if(miss)
			atMM <= 1'b1;
		else if(outMM>=2'b11)
			atMM <= 1'b0;
	end
	 
	 //emulates delay going to MM
	 always @(posedge clk)begin
		if(atMM) outMM <= outMM+1;
		else outMM <=0;
	 end
	 
	 
	 //writes back to cache
	 always @(posedge clk)begin
		way1set0 <= way1[0][31:0];
		way1set2 <= way1[2][31:0];
		way1set255 <= way1[255][31:0];
		if(~atMM && state[2])begin
			way1[reg_addr[7:0]][31:0] <= 32'hBBBB_BBBB;
			way1[reg_addr[7:0]][31:0] <= 32'hBBBB_BBBB;
			way1[reg_addr[7:0]][31:0] <= 32'hBBBB_BBBB;
			
		end
			
		else begin
			way1[0][31:0] <= 32'h0001_AAAA;
			way1[2][31:0] <= 32'h0001_AAAA;
			way1[255][31:0] <= 32'h0001_AAAA;
		end
	end
	
	reg [1:0] written;
	
	//test LRU
	always @(posedge clk) begin
		way1set0 <= way1[0][57:56];
		way2set0 <= way2[0][57:56];
		way3set0 <= way3[0][57:56];
		way4set0 <= way4[0][57:56];
		way1data <= way1[0][31:0];
		way2data <= way2[0][31:0];
		way3data <= way3[0][31:0];
		way4data <= way4[0][31:0];
		if(we && state[2])begin //if goes to memory
			if(way1[reg_addr[7:0]][57:56] == 2'b11)begin
				//write to this way
				way1[reg_addr[7:0]][31:0] <= 32'hF00F_AAAA;
				written <= 2'b00;
			end
			else if(way2[reg_addr[7:0]][57:56] == 2'b11)begin
				//write to this way
				way2[reg_addr[7:0]][31:0] <= 32'hF00F_BBBB;
				written <= 2'b01;
			end
			else if(way3[reg_addr[7:0]][57:56] == 2'b11)begin
				//write to this way
				way3[reg_addr[7:0]][31:0] <= 32'hF00F_CCCC;
				written <= 2'b10;
			end
			else if(way4[reg_addr[7:0]][57:56] == 2'b11)begin
				//write to this way
				way4[reg_addr[7:0]][31:0] <= mem_data;
				written <= 2'b11;
			end
		
		end
	end//end of initial LRU
	
	//LRU control algorithmn -- updates last used
	always @(posedge clk) begin
		if(written == 2'b00 && state[3])begin
			way1[reg_addr[7:0]][57:56] <= 2'b00;
			way2[reg_addr[7:0]][57:56] <= way2[reg_addr[7:0]][57:56] + 1'b1;
			way3[reg_addr[7:0]][57:56] <= way3[reg_addr[7:0]][57:56] + 1'b1;
			way4[reg_addr[7:0]][57:56] <= way4[reg_addr[7:0]][57:56] + 1'b1;
		end
		else if(written == 2'b01 && state[3])begin
			way1[reg_addr[7:0]][57:56] <= way1[reg_addr[7:0]][57:56] + 1'b1;
			way2[reg_addr[7:0]][57:56] <= 2'b00;
			way3[reg_addr[7:0]][57:56] <= way3[reg_addr[7:0]][57:56] + 1'b1;
			way4[reg_addr[7:0]][57:56] <= way4[reg_addr[7:0]][57:56] + 1'b1;
		end
		else if(written == 2'b10 && state[3])begin
			way1[reg_addr[7:0]][57:56] <= way1[reg_addr[7:0]][57:56] + 1'b1;
			way2[reg_addr[7:0]][57:56] <= way2[reg_addr[7:0]][57:56] + 1'b1;
			way3[reg_addr[7:0]][57:56] <= 2'b00;
			way4[reg_addr[7:0]][57:56] <= way4[reg_addr[7:0]][57:56] + 1'b1;
		end
		else if(written == 2'b11 && state[3] )begin
			way1[reg_addr[7:0]][57:56] <= way1[reg_addr[7:0]][57:56] + 1'b1;
			way2[reg_addr[7:0]][57:56] <= way2[reg_addr[7:0]][57:56] + 1'b1;
			way3[reg_addr[7:0]][57:56]<= way3[reg_addr[7:0]][57:56] + 1'b1;
			way4[reg_addr[7:0]][57:56] <= 2'b00;
		end
	end

endmodule
