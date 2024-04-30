// This module takes 3 inputs; 1 selects and 2 inputs and uses these to give an out for a 2x1 multiplexer.
`timescale 1ns/10ps
module mux2_1(out, i0, i1, sel);
	output logic out;
	// i0 and i1 are input ports to the multiplexer
	// sel is the select line to the multiplexer
   input logic i0, i1, sel;
	
	// out = (i1 & sel) | (i0 & ~sel)
	logic and1, and2, notsel;

	//not #50 notselcomp (notsel, sel);
	//and #50 i1andsel (and1, i1, sel);
	//and #50 i0andnotsel (and2, i0, notsel);
	//or #50 muxout (out, and1, and2);
	not #50 notselcomp (notsel, sel);
	and #50 i1andsel (and1, i1, sel);
	and #50 i0andnotsel (and2, i0, notsel);
	or #50 muxout (out, and1, and2);
endmodule

// creates a 4 bit in and out 2 port mux
module mux2_1_4 (out, i0, i1, sel);
	output logic [3:0] out;
	input logic sel;
	input logic [3:0] i0, i1;

	genvar i;
	generate
		for(i=0; i<4; i++) begin : eachmux
			mux2_1 muxs (.out(out[i]), .i0(i0[i]), .i1(i1[i]), .sel);
		end
	endgenerate
endmodule

// creates a 5 bit in and out 2 port mux
module mux2_1_5 (out, i0, i1, sel);
	output logic [4:0] out;
	input logic sel;
	input logic [4:0] i0, i1;

	genvar i;
	generate
		for(i=0; i<5; i++) begin : eachmux
			mux2_1 muxs (.out(out[i]), .i0(i0[i]), .i1(i1[i]), .sel);
		end
	endgenerate
endmodule

// creates a 64 bit in and out 2 port mux
module mux2_1_64 (out, i0, i1, sel);
	output logic [63:0] out;
	input logic sel;
	input logic [63:0] i0, i1;

	genvar i;
	generate
		for(i=0; i<64; i++) begin : eachmux
			mux2_1 muxs (.out(out[i]), .i0(i0[i]), .i1(i1[i]), .sel);
		end
	endgenerate
endmodule

// start of the 2x1 multiplexer testbench
module mux2_1_testbench();
	// repeats the variables as explained above
	logic i0, i1, sel;
	logic out; 
	// initializes the mux2_1 module with the reference varibles
	mux2_1 dut (.out, .i0, .i1, .sel);
	initial begin
	// tests all possible outputs of sel, i0 and i1
		sel=0; i0=0; i1=0; #100;
		sel=0; i0=0; i1=1; #100;
		sel=0; i0=1; i1=0; #100;
		sel=0; i0=1; i1=1; #100;
		sel=1; i0=0; i1=0; #100;
		sel=1; i0=0; i1=1; #100;
		sel=1; i0=1; i1=0; #100;
		sel=1; i0=1; i1=1; #100;
	end
endmodule

// This module takes 3 inputs: 2 bit wide sel, 4 bits of in and 1 bit of out. These will be used to create
// a 4x1 mux
module mux4_1(out, in, sel);
	output logic out;
	input logic [3:0] in;
	input logic [1:0] sel;

	// these are internal wires that like two 2x1 multiplexers to the final 2x1 multiplexer
	logic v0, v1;
	// simulating the code for the 3 2x1 multiplexers from mux2_1 verilog
	mux2_1 m0(.out(v0), .i0(in[0]), .i1(in[1]), .sel(sel[0]));
	mux2_1 m1(.out(v1), .i0(in[2]), .i1(in[3]), .sel(sel[0]));
	mux2_1 m2 (.out(out), .i0(v0), .i1(v1), .sel(sel[1]));
endmodule

// This module takes 3 inputs: 3 bit wide sel, 8 bits of in and 1 bit of out. These will be used to create
// a 8x1 mux
module mux8_1(out, in, sel);
	output logic out;
	input logic [7:0] in;
	input logic [2:0] sel;

	// these are internal wires that like two 4x1 multiplexers to a final 2x1 multiplexer
	logic v0, v1;
	// simulating the code for the 2 4x1 multiplexers and 1 2x1 from mux2_1 and mux4_1 verilog
	mux4_1 m0(.out(v0), .in(in[3:0]), .sel(sel[1:0]));
	mux4_1 m1(.out(v1), .in(in[7:4]), .sel(sel[1:0]));
	mux2_1 m2 (.out(out), .i0(v0), .i1(v1), .sel(sel[2]));
endmodule

// This module takes 3 inputs: 4 bit wide sel, 16 bits of in and 1 bit of out. These will be used to create
// a 16x1 mux
module mux16_1(out, in, sel);
	output logic out;
	input logic [15:0] in;
	input logic [3:0] sel;

	// these are internal wires that like two 8x1 multiplexers to a final 2x1 multiplexer
	logic v0, v1;
	// simulating the code for the 2 8x1 multiplexers and 1 2x1 from mux2_1 and mux4_1 verilog
	mux8_1 m0(.out(v0), .in(in[7:0]), .sel(sel[2:0]));
	mux8_1 m1(.out(v1), .in(in[15:8]), .sel(sel[2:0]));
	mux2_1 m2 (.out(out), .i0(v0), .i1(v1), .sel(sel[3]));
endmodule

// start of the 16x1 multiplexer testbench
// used to test some basic outputs to ensure functionality
module mux16_1_testbench();
	logic out;
	logic [15:0] in;
	logic [3:0] sel;
	mux16_1 dut (.out, .in, .sel);
	initial begin
		sel=4'b0000; in={16{1'b0}}; #100;
		sel=4'b0000; in[0]=1;    #100;
		sel=4'b1111; in[15]=0;   #100;
		sel=4'b1111; in[15]=1;   #100;
		sel=4'b0011; in[3]=0;    #100;
		sel=4'b0011; in[3]=1;    #100;
	end
endmodule

// This module takes 3 inputs: 5 bit wide sel, 32 bits of in and 1 bit of out. These will be used to create
// a 32x1 mux
module mux32_1(out, in, sel);
	output logic out;
	input logic [31:0] in;
	input logic [4:0] sel;

	// these are internal wires that like two 16x1 multiplexers to a final 2x1 multiplexer
	logic v0, v1;
	// simulating the code for the 2 8x1 multiplexers and 1 2x1 from mux2_1 and mux4_1 verilog
	mux16_1 m0(.out(v0), .in(in[15:0]), .sel(sel[3:0]));
	mux16_1 m1(.out(v1), .in(in[31:16]), .sel(sel[3:0]));
	mux2_1 m2 (.out(out), .i0(v0), .i1(v1), .sel(sel[4]));
endmodule

module mux64_32_1(out, in, sel);
	output logic [63:0] out;
	input logic  [63:0] in [31:0];
	input logic [4:0] sel;

	genvar i;
	genvar j;
	
	//logic [31:0] inte;
	
	generate
		for(i=0; i<64; i++) begin : eachDff
			//for(j=0; j<32; j++) begin : eachfan
			//	inte[j] <= in[j];//[i];
			//end
			mux32_1 muxs (.out(out[i]), .in({1'b0,in[30][i],in[29][i],in[28][i],in[27][i],in[26][i],
													   in[25][i],in[24][i],in[23][i],in[22][i],in[21][i],in[20][i],
														in[19][i],in[18][i],in[17][i],in[16][i],in[15][i],in[14][i],
														in[13][i],in[12][i],in[11][i],in[10][i],in[9][i],in[8][i],
														in[7][i],in[6][i],in[5][i],in[4][i],in[3][i],in[2][i], 
														in[1][i],in[0][i]}), .sel);
		end
	endgenerate
endmodule

module mux64_32_1_testbench();
	logic [63:0] out;
	logic [63:0] in [31:0];
	logic [4:0] sel;
	integer i;
	mux64_32_1 dut (.out, .in, .sel);
	initial begin
		for (i=0; i<32; i++) begin
			in[i]={64{1'b0}};
		end 
		sel=5'b00000; in[0]={64{1'b0}}; #100;
		sel=5'b00000; in[0]={64{1'b1}}; #100;
		sel=5'b00001; in[1]={64{1'b0}}; #100;
		sel=5'b00001; in[1]={64{1'b1}}; #100;
		sel=5'b11111; in[31]={64{1'b0}}; #100;
		sel=5'b11111; in[31]={64{1'b1}}; #100;
		sel=5'b00011; in[3]={64{1'b0}}; #100;
		sel=5'b00011; in[3]={{2{1'b0}},{62{1'b1}}}; #100;
	
	end
endmodule

// This module takes 3 inputs: 6 bit wide sel, 64 bits of in and 1 bit of out. These will be used to create
// a 64x1 mux
module mux64_1(out, in, sel);
	output logic out;
	input logic [63:0] in;
	input logic [5:0] sel;

	// these are internal wires that like two 32x1 multiplexers to a final 2x1 multiplexer
	logic v0, v1;
	// simulating the code for the 2 8x1 multiplexers and 1 2x1 from mux2_1 and mux4_1 verilog
	mux32_1 m0(.out(v0), .in(in[31:0]), .sel(sel[4:0]));
	mux32_1 m1(.out(v1), .in(in[63:32]), .sel(sel[4:0]));
	mux2_1 m2 (.out(out), .i0(v0), .i1(v1), .sel(sel[5]));
endmodule

// start of the 16x1 multiplexer testbench
// used to test some basic outputs to ensure functionality
module mux64_1_testbench();
	logic out;
	logic [63:0] in;
	logic [5:0] sel;
	mux64_1 dut (.out, .in, .sel);
	initial begin
		sel=6'b000000; in={64{1'b0}}; #100;
		sel=6'b000000; in[0]=1;       #100;
		sel=6'b000100; in[4]=0;       #100;
		sel=6'b000100; in[4]=1;       #100;
		sel=6'b111111; in[63]=0;      #100;
		sel=6'b111111; in[63]=1;      #100;
		sel=6'b111100; in[60]=0;      #100;
		sel=6'b111100; in[60]=1;      #100;
	end
endmodule

// This module takes 3 inputs: 2 bit wide sel, 4 64 bit of in and 1 bit of out. These will be used to create
// a 4x1 mux
module mux4_1_64 (out, i0, i1, i2, i3, sel);
	output logic [63:0] out;
	input logic [63:0] i0, i1, i2, i3;
	input logic [1:0] sel;

	// these are internal wires that like two 2x1 multiplexers to the final 2x1 multiplexer
	logic [63:0] v0, v1;
	// simulating the code for the 3 2x1 multiplexers from mux2_1_64 verilog
	mux2_1_64 m0(.out(v0), .i0(i0), .i1(i1), .sel(sel[0]));
	mux2_1_64 m1(.out(v1), .i0(i2), .i1(i3), .sel(sel[0]));
	mux2_1_64 m2 (.out(out), .i0(v0), .i1(v1), .sel(sel[1]));
endmodule