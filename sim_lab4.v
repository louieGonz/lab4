`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   21:52:08 02/28/2015
// Design Name:   lab4
// Module Name:   C:/Users/lgonza20/Desktop/lab4/lab4/sim_lab4.v
// Project Name:  lab4
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: lab4
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module sim_lab4;

	// Inputs
	reg gclk;
	reg rd;
	reg [31:0] addr;
	reg we;
	reg [31:0] mem_data;

	// Outputs
	wire rst;
	wire valid;
	wire [31:0] mem_addr;
	wire [31:0] data;

	// Instantiate the Unit Under Test (UUT)
	lab4 uut (
		.gclk(gclk), 
		.rd(rd), 
		.addr(addr), 
		.we(we), 
		.mem_data(mem_data), 
		.rst(rst), 
		.valid(valid), 
		.mem_addr(mem_addr), 
		.data(data)
	);

	initial begin
		// Initialize Inputs
		gclk = 0;
		rd = 0;
		addr = 0;
		we = 0;
		mem_data = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		
			#5
			rd=1;
			mem_data = 32'hAAAA_AAAA;
			addr = 32'hFFFF_FFFF;
			gclk = 1;
			#5
			gclk=0;
			#5
			gclk=1;
			rd=0;
			addr = 32'h0000_0000;
			#5
			gclk=0;
			#5
			gclk=1;
			#5
			gclk=0;
			#5
			gclk=1;
			#5
			gclk=0;
			#5
			gclk=1;
			#5
			gclk=0;
			#5
			gclk=1;
			#5
			gclk=0;
			#5
			gclk=1;
			#5
			gclk=0;
			#5
			gclk=1;
			#5
			gclk=0;
			#5
			gclk=1;
			#5
			gclk=0;
			#5
			gclk=1;
			#5
			gclk=0;
			#5
			gclk=1;
			#5
			gclk=0;
			#5
			gclk=1;
			#5
			gclk=0;
			#5
			gclk=1;
			#5
			gclk=0;
			#5
			gclk=1;
			#5
			gclk=0;
			#5
			gclk=1;
			#5
			gclk=0;
			#5
			gclk=1;
			#5
			gclk=0;
			#5
			gclk=1;
			#5
			gclk=0;
			#5
			gclk=1;
			#5
			gclk=0;
			#5
			gclk=1;
			#5
			gclk=0;
			#5
			gclk=1;
			#5
			gclk=0;
			#5
			gclk=1;
			#5
			gclk=0;
			#5
			gclk=1;
			#5
			gclk=0;
			#5
			gclk=1;
			#5
			gclk=0;
			#5
			gclk=1;
			#5
			gclk=0;
			#5
			gclk=1;
			#5
			gclk=0;
			
		
		

	end
      
endmodule

