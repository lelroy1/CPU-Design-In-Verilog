`timescale 1ns/10ps

module signextend9(imm9, out);
	input logic [8:0] imm9;
	output logic [63:0] out;

	assign out = {{55{imm9[8]}}, imm9};
endmodule

module signextend9_testbench();
	// repeats the variables as explained above
	logic [8:0] imm9;
	logic [63:0] out; 
	// initializes the mux2_1 module with the reference varibles
	signextend9 dut (.imm9, .out);
	initial begin
	// tests all possible outputs of sel, i0 and i1
		imm9=9'b001101010; #100;
		imm9=9'b101101010; #100;
	end
endmodule

module zeroextend9(imm9, out);
	input logic [8:0] imm9;
	output logic [63:0] out;

	assign out = {{55{1'b0}}, imm9};
endmodule

module signextend12(imm12, out);
	input logic [11:0] imm12;
	output logic [63:0] out;

	assign out = {{52{imm12[11]}}, imm12};
endmodule

module zeroextend12(imm12, out);
	input logic [11:0] imm12;
	output logic [63:0] out;

	assign out = {{52{1'b0}}, imm12};
endmodule

module signextend16(imm16, out);
	input logic [15:0] imm16;
	output logic [63:0] out;

	assign out = {{48{imm16[15]}}, imm16};
endmodule

module zeroextend16(imm16, out);
	input logic [15:0] imm16;
	output logic [63:0] out;

	assign out = {{48{1'b0}}, imm16};
endmodule

module signextend19(imm19, out);
	input logic [18:0] imm19;
	output logic [63:0] out;

	assign out = {{45{imm19[18]}}, imm19};
endmodule

module zeroextend19(imm19, out);
	input logic [18:0] imm19;
	output logic [63:0] out;

	assign out = {{45{1'b0}}, imm19};
endmodule

module signextend26(imm26, out);
	input logic [25:0] imm26;
	output logic [63:0] out;

	assign out = {{38{imm26[25]}}, imm26};
endmodule

module zeroextend26(imm26, out);
	input logic [25:0] imm26;
	output logic [63:0] out;

	assign out = {{38{1'b0}}, imm26};
endmodule