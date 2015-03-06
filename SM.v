`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:45:48 02/26/2015 
// Design Name: 
// Module Name:    SM 
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
module SM(clk,rd,hit,miss,we,rst,state);
	input clk,rd,hit,miss,we,rst;
	output reg [5:0] state;

	
	reg [5:0] next_state;
	
	parameter idle = 6'b00_0001,
				 inCache = 6'b00_0010,
				 pullMM = 6'b00_0100,
				 upLRU = 6'b00_1000,
				 dataReady = 6'b01_0000,
				 reset = 6'b10_0000;
				 
	always @(*) begin
		case(state)
			idle:
				if(rd) next_state <= inCache;
				else if(rst) next_state <= reset;
				else next_state <= next_state;
			inCache:
				if(hit) next_state <= dataReady; //also need to send
				else if(miss) next_state <= pullMM;
				else if(rst) next_state <= reset;
				else next_state <= next_state;
			pullMM:
				if(we) next_state <= upLRU;
				else if(rst) next_state <= reset;
				else next_state <= next_state;
			upLRU:
				next_state <= dataReady;
			dataReady:   								//here when rdy to sent data
				next_state <= idle;
			reset:
				next_state <= idle;
			default:
				next_state <= idle; 					//a crash somewhere
		endcase
	end
	
	always @(posedge clk)begin
		state <= next_state;
	end

endmodule
