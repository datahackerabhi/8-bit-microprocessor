`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   16:42:18 11/02/2017
// Design Name:   EU
// Module Name:   D:/ee16b058_ee16b060/processor_modified/eutest.v
// Project Name:  processor_modified
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: EU
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module test_bench_cu;

	// Inputs
	reg clk;

	// Outputs
	wire [7:0] debug,debug1,debug2;

	// Instantiate the Unit Under Test (UUT)
        CU uut (.clk(clk),.debug(debug),.debug1(debug1),.debug2(debug2));

	initial begin
		// Initialize Inputs
		clk = 0;
		#1000;
		$finish;
		end
		always 
		#10 clk = ~clk;
        
		

	initial
 begin
    $dumpfile("test_bench_cu.vcd");
    $dumpvars(0,test_bench_cu);
 end
	
      
endmodule

