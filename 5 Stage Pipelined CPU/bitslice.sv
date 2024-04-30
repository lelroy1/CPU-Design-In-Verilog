// bitslice that uses six control operations: 
// b output, a + b, a - b, a & b, a | b, a xor b
// and outputs it into the alu_out. The operations are selected as follows:
// sel			Operation
// 000:			result = B
// 010:			result = A + B
// 011:			result = A - B
// 100:			result = bitwise A & B
// 101:			result = bitwise A | B
// 110:			result = bitwise A XOR B
// The add and subtract operations will take a carry in and create a carry out 
`timescale 1ns/10ps
module bitslice (a, b, ci, sel, alu_out, co);
    input logic a, b, ci;
    input logic [2:0] sel;
    output logic co, alu_out;

    logic [7:0] in_signals;
    logic b_mux;
    logic not_b;
    logic a_and_b, a_or_b, a_xor_b;

    // mux for adding and subtracting
    not #50 not_b_gate (not_b, b);
    mux2_1 sub_add (.out(b_mux), .i0(b), .i1(not_b), .sel(sel[0]));
    
    assign in_signals[0] = b;
    adder add_op (.ci, .a, .b(b_mux), .co, .out(in_signals[2]));
    assign in_signals[3] = in_signals[2];

    and #50 and_gate1 (in_signals[4], a, b);
    or #50 or_gate1 (in_signals[5], a, b);
    xor #50 xor_gat1 (in_signals[6], a, b);

    mux8_1 mux (.out(alu_out), .in(in_signals), .sel); 

endmodule

// test bench for the bitslice module that will test functionality of all selected 
// operations.
module bitslice_tb();
    logic a, b, ci;
    logic [2:0] sel;
    logic co, alu_out;

bitslice dut (.a, .b, .ci, .sel, .alu_out, .co);

    initial begin
	// tests some possible outputs of a,b,ci and sel

        // sel = 000 where b should go into alu out
		a=1'b0; b=1'b1; ci=1'b1; sel=3'b000; #10000;      
		a=1'b1; b=1'b1; ci=1'b0; sel=3'b000; #10000;      
		a=1'b0; b=1'b0; ci=1'b1; sel=3'b000; #10000;
        
        // sel = 010 where a+b should go into alu out      
		a=1'b1; b=1'b0; ci=1'b0; sel=3'b010; #10000;       
		a=1'b1; b=1'b0; ci=1'b1; sel=3'b010; #10000;
		a=1'b1; b=1'b1; ci=1'b1; sel=3'b010; #10000;
		a=1'b1; b=1'b1; ci=1'b0; sel=3'b010; #10000;
		a=1'b0; b=1'b1; ci=1'b0; sel=3'b010; #10000;
		a=1'b0; b=1'b0; ci=1'b1; sel=3'b010; #10000;
		a=1'b0; b=1'b0; ci=1'b0; sel=3'b010; #10000;
		a=1'b0; b=1'b1; ci=1'b1; sel=3'b010; #10000;

        // sel = 011 where a-b should go into alu out
		a=1'b1; b=1'b0; ci=1'b0; sel=3'b011; #10000;       
		a=1'b1; b=1'b0; ci=1'b1; sel=3'b011; #10000;
		a=1'b1; b=1'b1; ci=1'b1; sel=3'b011; #10000;
		a=1'b1; b=1'b1; ci=1'b0; sel=3'b011; #10000;
		a=1'b0; b=1'b1; ci=1'b0; sel=3'b011; #10000;
		a=1'b0; b=1'b0; ci=1'b1; sel=3'b011; #10000;
		a=1'b0; b=1'b0; ci=1'b0; sel=3'b011; #10000;
		a=1'b0; b=1'b1; ci=1'b1; sel=3'b011; #10000;

        // sel = 100 A & B into alu out
		a=1'b0; b=1'b0; ci=1'b1; sel=3'b100; #10000;      
		a=1'b0; b=1'b1; ci=1'b0; sel=3'b100; #10000;      
		a=1'b1; b=1'b0; ci=1'b1; sel=3'b100; #10000;
		a=1'b1; b=1'b1; ci=1'b1; sel=3'b100; #10000;

        // sel = 101 A | B into alu out
		a=1'b0; b=1'b0; ci=1'b1; sel=3'b101; #10000;      
		a=1'b0; b=1'b1; ci=1'b0; sel=3'b101; #10000;      
		a=1'b1; b=1'b0; ci=1'b1; sel=3'b101; #10000;
		a=1'b1; b=1'b1; ci=1'b1; sel=3'b101; #10000;

        // sel = 110 A XOR B into alu out
		a=1'b0; b=1'b0; ci=1'b1; sel=3'b110; #10000;      
		a=1'b0; b=1'b1; ci=1'b0; sel=3'b110; #10000;      
		a=1'b1; b=1'b0; ci=1'b1; sel=3'b110; #10000;
		a=1'b1; b=1'b1; ci=1'b1; sel=3'b110; #10000;
	end
endmodule
