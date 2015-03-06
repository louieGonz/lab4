`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   21:58:54 03/05/2015
// Design Name:   cache_test
// Module Name:   C:/Users/one/Desktop/lab4_3_1_1150pm/random_test_bench.v
// Project Name:  lab4
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: cache_test
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module random_test_bench;

	// Inputs
	reg clk;
	reg rst;
	reg we;
	reg [31:0] mem_data;
	reg rd;
	reg [31:0] addr;

	// Outputs
	wire [31:0] mem_addr;
	wire valid;
	wire [31:0] data;
	wire hit;
	wire miss;
	wire [2:0] way;
	wire [23:0] tag;
	wire [23:0] tag_check;
	wire [1:0] lru1;
	wire [1:0] lru2;
	wire [1:0] lru3;
	wire [1:0] lru4;
	wire [5:0] state;

	// Instantiate the Unit Under Test (UUT)
	cache_test uut (
		.clk(clk), 
		.rst(rst), 
		.we(we), 
		.mem_data(mem_data), 
		.mem_addr(mem_addr), 
		.rd(rd), 
		.addr(addr), 
		.valid(valid), 
		.data(data), 
		.hit(hit), 
		.miss(miss), 
		.way(way), 
		.tag(tag), 
		.tag_check(tag_check), 
		.lru1(lru1), 
		.lru2(lru2), 
		.lru3(lru3), 
		.lru4(lru4), 
		.state(state)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		rst = 0;
		we = 0;
		mem_data = 0;
		rd = 0;
		addr = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here

	end
      
endmodule

