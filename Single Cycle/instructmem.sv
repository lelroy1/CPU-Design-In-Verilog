// WARNING NOT DEVELOPED BY ME: This was a file that was found on the internet and slightly modified

`define BENCHMARK "../benchmarks/test1.arm"

`timescale 1ns/10ps

`define INSTRUCT_MEM_SIZE		1024
	
module instructmem (
	input logic		[63:0]	address,
	output logic		[31:0]	instruction,
	input logic clk
	);
	
	// The data storage itself.
	logic [31:0] mem [`INSTRUCT_MEM_SIZE/4-1:0];
	
	// Load the program - change the filename to pick a different program.
	initial begin
		$readmemb(`BENCHMARK, mem);
		$display("Running benchmark: ", `BENCHMARK);
	end
	
	// Handle the reads.
	integer i;
	always_comb begin
		if (address + 3 >= `INSTRUCT_MEM_SIZE)
			instruction = 'x;
		else
			instruction = mem[address/4];
	end
		
endmodule

module instructmem_testbench ();

	parameter ClockDelay = 5000;

	logic [63:0]	address;
	logic clk;
	logic [31:0]	instruction;
	
	instructmem dut (.address, .instruction, .clk);
	
	initial begin // Set up the clock
		clk <= 0;
		forever #(ClockDelay/2) clk <= ~clk;
	end
	
	integer i;
	initial begin
		// Read every location
		for (i=0; i <= `INSTRUCT_MEM_SIZE; i = i + 4) begin
			address <= i;
			@(posedge clk); 
		end
		$stop;
		
	end
endmodule
