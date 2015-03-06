`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:22:46 03/01/2015 
// Design Name: 
// Module Name:    cache_write_task 
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
module cache_write_task(
    );
	 
	 task wb;
	 input miss;
	 output [31:0] mem_data;
	 output we;
	 
	 begin
		mem_data = 32'h5678_5678;
	 end
	 endtask
	
	 
endmodule
