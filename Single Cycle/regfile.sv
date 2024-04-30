// Top level module that utilizes mux, decoders and register modules.
// Creates a Register with two read inputs, a write input, write data input,
// and register write input. With these inputs it outputs two read registers.
`timescale 1ns/10ps
module regfile (ReadData1, ReadData2, WriteData, ReadRegister1, ReadRegister2, WriteRegister, RegWrite, clk);
	input logic [63:0] WriteData;
	input logic [4:0] ReadRegister1, ReadRegister2, WriteRegister;
	input logic RegWrite, clk;
	output logic [63:0] ReadData1, ReadData2;
	
	logic [31:0] reg_wires;
	logic [63:0] mux_wires [31:0];
	decoder_5_32 Decoder (.sel(WriteRegister), .en(RegWrite), .out(reg_wires));
	
	genvar i;
	generate
		for(i=0; i<31; i++) begin : eachDff
			register regs (.d(WriteData), .wren(reg_wires[i]), .clk, .q(mux_wires[i]));
		end
	endgenerate
	
	assign mux_wires[31] = {64{1'b0}};
	mux64_32_1 topmux (.out(ReadData1), .in(mux_wires), .sel(ReadRegister1));
	mux64_32_1 botmux (.out(ReadData2), .in(mux_wires), .sel(ReadRegister2));
endmodule 

// A module that creates a 64 bit register with a write enable feature.
// Takes inputs d, wren and clock. It outputs q on posedge of the clk.
module register(d, wren, clk, q);
	input logic [63:0] d;
	input logic wren, clk;
	output logic [63:0] q;
	
	// wire used to buffer input to register to add wren capability
	logic [63:0] out;
	
	genvar i;
	generate
		for(i=0; i<64; i++) begin : eachDff
			mux2_1 muxs (.out(out[i]), .i0(q[i]), .i1(d[i]), .sel(wren));
			D_FF dffs(.q(q[i]), .d(out[i]), .reset(1'b0), .clk);
		end
	endgenerate
endmodule 

// testbench for the register module to verify correct functionality
module register_tb();
	logic [63:0] d;
	logic wren, clk;
	logic [63:0] q;
	
	register dut (.d, .wren, .clk, .q);
	
	initial begin // Set up the clock
		clk <= 0;
		forever #(5000/2) clk <= ~clk;
	end
	
	initial begin
		wren<=1; d<={64{1'b1}}; @(posedge clk);
		wren<=0; d<={64{1'b0}}; @(posedge clk);
		wren<=0; d<={64{1'b0}}; @(posedge clk);
		wren<=1; d<={{61{1'b1}}, {3{1'b0}}}; @(posedge clk);
		wren<=0; d<={64{1'b0}}; @(posedge clk);
		wren<=0; d<={64{1'b1}}; @(posedge clk);
		@(posedge clk);
		$stop;
	end
endmodule