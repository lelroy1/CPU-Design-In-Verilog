`timescale 1ns/10ps

// logically shifts the given 64 bit input left by 2
module lsl2(in, out);
	input logic [63:0] in;
	output logic [63:0] out;

	assign out[0] = 1'b0;
	assign out[1] = 1'b0;

	genvar i;
	generate 
		for(i=0; i<62; i++) begin : shift_connections	
			assign out[i+2]	= in[i];
		end
	endgenerate

endmodule

// creates logic for the mov fucntions
module mov (movk, shamt, imm16, reg_data, result);
	input logic [63:0] reg_data;
	input logic [15:0] imm16;
	input logic [1:0] shamt;
	input logic movk;
	output logic [63:0] result;

	logic [63:0] shift_data;
	mux2_1_64 shiftmux (.out(shift_data), .i0(64'd0), .i1(reg_data), .sel(movk));

	logic [63:0] out_0, out_1, out_2, out_3;
	assign out_0 = {shift_data[63:16], imm16};
	assign out_1 = {shift_data[63:32], imm16, shift_data[15:0]};
	assign out_2 = {shift_data[63:48], imm16, shift_data[31:0]};	
	assign out_3 = {imm16, shift_data[47:0]};	

	// shamt 5 and 4 becuase mov implies shamt must be 0 16 32 or 48
	mux4_1_64 shiftmuxtop (.out(result), .i0(out_0), .i1(out_1), .i2(out_2), .i3(out_3), .sel(shamt));
endmodule