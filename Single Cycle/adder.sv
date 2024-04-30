// This module uses explicit logic gates to define a full adder.
`timescale 1ns/10ps
module adder (a, b, ci, out, co);
    input logic a, b, ci;
    output logic co, out;

    logic a_xor_b, a_and_b;

    xor #50 a_xor_b_gate (a_xor_b, a, b);
    and #50 a_and_b_gate (a_and_b, a, b);

    xor #50 xor_xor_cin_gate (out, a_xor_b, ci);
    and #50 xor_and_cin_gate (xor_and_cin, a_xor_b, ci);

    or #50 and_or_a_and_b (co, a_and_b, xor_and_cin);
endmodule

// Testbench for full adder module which tests all possible combinations of inputs.
module adder_tb();
    logic a, b, ci;
    logic co, out;

    adder dut (.a, .b, .ci, .out, .co);

    initial begin
	// tests all possible outputs of a, b and ci
		a=1'b1; b=1'b0; ci=1'b0; #1000;       
		a=1'b1; b=1'b0; ci=1'b1; #1000;
		a=1'b1; b=1'b1; ci=1'b1; #1000;
		a=1'b1; b=1'b1; ci=1'b0; #1000;
		a=1'b0; b=1'b1; ci=1'b0; #1000;
		a=1'b0; b=1'b0; ci=1'b1; #1000;
		a=1'b0; b=1'b0; ci=1'b0; #1000;
		a=1'b0; b=1'b1; ci=1'b1; #1000;
	end
endmodule

module bitadder64 (a, b, out);
    input logic [63:0] a, b;
    output logic [63:0] out;

	logic [63:0] int_wire;

	adder inital_adder (.a(a[0]), .b(b[0]), .ci(1'b0), .out(out[0]), .co(int_wire[0]));

	genvar i;	
	generate 
		for(i=1; i<64; i++) begin : bitslice_connections	
			adder adds (.a(a[i]), .b(b[i]), .ci(int_wire[i-1]), .out(out[i]), .co(int_wire[i]));
		end
	endgenerate

endmodule

// Testbench for full adder module which tests all possible combinations of inputs.
module bitadder64_tb();
    logic [63:0] a, b;
    logic [63:0] out;

    bitadder64 dut (.a, .b, .out);

    initial begin
	// tests all possible outputs of a, b and ci
		a=64'd0; b=64'd4; #1000;
		a=64'd16; b=64'd32; #1000;
		a=64'd416; b=64'd408; #1000;
	end
endmodule
