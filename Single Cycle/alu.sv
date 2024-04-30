// 64 bit alu that uses six control operations: 
// b output, a + b, a - b, a & b, a | b, a xor b
// and outputs it into the alu_out. The operations are selected as follows:
// cntrl			Operation
// 000:			result = B
// 010:			result = A + B
// 011:			result = A - B
// 100:			result = bitwise A & B
// 101:			result = bitwise A | B
// 110:			result = bitwise A XOR B
// The add and subtract operations create logic of a overflow, carryout and 
// negative. There is also a zero flag that will be high whenever the resulting 
// 64 bit output is negative
`timescale 1ns/10ps
module alu (A, B, cntrl, result, zero, overflow, carry_out, negative);
    input logic [63:0] A, B;
    input logic [2:0] cntrl;
    output logic [63:0] result;
	output logic zero, overflow, carry_out, negative;

	logic [64:0] int_wire;

	bitslice inital_slice (.a(A[0]), .b(B[0]), .ci(cntrl[0]), .sel(cntrl), .alu_out(result[0]), .co(int_wire[0]));

	genvar i;	
	generate 
		for(i=1; i<64; i++) begin : bitslice_connections	
			bitslice last_slices (.a(A[i]), .b(B[i]), .ci(int_wire[i-1]), .sel(cntrl), .alu_out(result[i]), .co(int_wire[i]));
		end
	endgenerate
	
	xor #50 overflow_gate (overflow, int_wire[63], int_wire[62]);
	assign carry_out = int_wire[63];	
	assign negative = result[63];

	// creates all the 4 input nor gates to create the zero output
	logic [15:0] first_nors;
	genvar j;
	generate
		for(i=0; i<64; i=i+4) begin : nor_connections	
			nor #50 first_layer (first_nors[i/4], result[i], result[i+1], result[i+2], result[i+3]);
		end
	endgenerate
		
	logic [3:0] second_nors;
	and #50 second_layer0 (second_nors[0], first_nors[0], first_nors[1], first_nors[2], first_nors[3]);
	and #50 second_layer1 (second_nors[1], first_nors[4], first_nors[5], first_nors[6], first_nors[7]);
	and #50 second_layer2 (second_nors[2], first_nors[8], first_nors[9], first_nors[10], first_nors[11]);
	and #50 second_layer3 (second_nors[3], first_nors[12], first_nors[13], first_nors[14], first_nors[15]);

	and #50 last_and (zero, second_nors[0], second_nors[1], second_nors[2], second_nors[3]);

endmodule