`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   18:44:08 02/26/2015
// Design Name:   SM
// Module Name:   C:/Users/lgonza20/Desktop/lab4/lab4/sim_SM.v
// Project Name:  lab4
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: SM
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module sim_SM;

	// Inputs
	reg clk;
	reg rd;
	reg hit;
	reg miss;
	reg we;
	reg rst;

	// Outputs
	wire [5:0] state;

	// Instantiate the Unit Under Test (UUT)
	SM uut (
		.clk(clk), 
		.rd(rd), 
		.hit(hit), 
		.miss(miss), 
		.we(we), 
		.rst(rst),
		.state(state)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		rd = 0;
		hit = 0;
		miss = 0;
		we = 0;
		//sentData = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		
		#5
		clk=1;
		#5
		clk=0;
		#5
		clk=1;
		#5
		clk=0;
		#5
		clk=1;
		rd=1;
		#5
		clk=0;
		#5
		clk=1;
		rd=0;
		#5
		clk=0;
		#5
		clk=1;
		#5
		clk=0;
		#5
		clk=1;
		
		#5
		clk=0;
		#5
		clk=1;
		
		#5
		clk=0;
		#5
		clk=1;
		#5
		clk=0;
		#5
		clk=1;
		miss=1;
		#5
		clk=0;
		#5
		clk=1;
		miss=0;
		#5
		clk=0;
		#5
		clk=1;
		we=1;
		#5
		clk=0;
		#5
		clk=1;
		we=0;
		#5
		clk=0;
		#5
		clk=1;
		#5
		clk=0;
		#5
		clk=1;
		#5
		clk=0;
		#5
		clk=1;
		#5
		clk=0;
		#5
		clk=1;
		#5
		clk=0;
		#5
		clk=1;
		rd=1;
		#5
		clk=0;
		#5
		clk=1;
		rd=0;
		#5
		clk=0;
		#5
		clk=1;
		#5
		clk=0;
		#5
		clk=1;
		#5
		clk=0;
		#5
		clk=1;
		#5
		clk=0;
		#5
		clk=1;
		#5
		clk=0;
		#5
		clk=1;
		#5
		clk=0;
		#5
		clk=1;
		rst=1;
		#5
		clk=0;
		#5
		clk=1;
		rst=0;
		#5
		clk=0;
		#5
		clk=1;
		#5
		clk=0;
		#5
		clk=1;
		#5
		clk=0;

	end
      
endmodule

