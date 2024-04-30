// creates a basic 2x4 decoder with a two bit select, 1 bit enable and 4 bit out
`timescale 1ps/1ps
module decoder_2_4(sel, en, out);
	input logic [1:0] sel;
	input logic en;
	output logic [3:0] out;
	
	logic notsel0, notsel1;
	
	not #50 notgate0 (notsel0, sel[0]);
	not #50 notgate1 (notsel1, sel[1]);
	and #50 andgate0 (out[0], notsel0, notsel1, en);
	and #50 andgate1 (out[1], sel[0], notsel1, en);
	and #50 andgate2 (out[2], notsel0, sel[1], en);
	and #50 andgate3 (out[3], sel[0], sel[1], en);
endmodule 

module decoder_2_4_testbench();
	// repeats the variables as explained above
	logic [1:0] sel;
	logic en;
	logic [3:0] out; 
	decoder_2_4 dut (.sel, .en, .out);
	initial begin
	// tests all possible outputs of sel, i0 and i1
		sel=2'b00; en = 1; #100;
		sel=2'b01; #100;
		sel=2'b10; #100;
		sel=2'b11; #100;
		sel=2'b00; en = 0; #100;
		sel=2'b01; #100;
		sel=2'b10; #100;
		sel=2'b11; #100;
	end
endmodule

// creates a basic 3x8 decoder with a 3 bit select, 1 bit enable and 8 bit out
module decoder_3_8(sel, en, out);
	input logic [2:0] sel;
	input logic en;
	output logic [7:0] out;
	
	logic notsel0, notsel1, notsel2;
	
	not #50 notgate0 (notsel0, sel[0]);
	not #50 notgate1 (notsel1, sel[1]);
	not #50 notgate2 (notsel2, sel[2]);
	
	and #50 andgate0 (out[0], notsel0, notsel1, notsel2, en);
	and #50 andgate1 (out[1], sel[0], notsel1, notsel2, en);
	and #50 andgate2 (out[2], notsel0, sel[1], notsel2, en);
	and #50 andgate3 (out[3], sel[0], sel[1], notsel2, en);
	and #50 andgate4 (out[4], notsel0, notsel1, sel[2], en);
	and #50 andgate5 (out[5], sel[0], notsel1,  sel[2], en);
	and #50 andgate6 (out[6], notsel0, sel[1],  sel[2], en);
	and #50 andgate7 (out[7], sel[0], sel[1],  sel[2], en);

endmodule 

// tests the basic 3x8 decoder
module decoder_3_8_testbench();
	// repeats the variables as explained above
	logic [2:0] sel;
	logic en;
	logic [7:0] out;
	decoder_3_8 dut (.sel, .en, .out);
	initial begin
		en =1;
		sel=3'b000; #1000;
		sel=3'b001; #1000;
		sel=3'b010; #1000;
		sel=3'b011; #1000;
		sel=3'b100; #1000;
		sel=3'b101; #1000;
		sel=3'b110; #1000;
		sel=3'b111; #1000;
		en =0;
		sel=3'b000; #1000;
		sel=3'b001; #1000;
		sel=3'b010; #1000;
		sel=3'b011; #1000;
		sel=3'b100; #1000;
		sel=3'b101; #1000;
		sel=3'b110; #1000;
		sel=3'b111; #1000;
		end
endmodule

// module that creates a 5x32 decoder using a 2x4 decoder and 3 3x8 decoders.
// takes 4 bit wide input sel and 32 bit out as parameters.
module decoder_5_32(sel, en, out);
	input logic [4:0] sel;
	input logic en;
	output logic [31:0] out;
	
	// intermediate wires that will route to each decoders en
	logic [3:0] v;
	
	decoder_2_4 decoder0 (.sel(sel[4:3]), .en(en), .out(v));
	decoder_3_8 decoder1 (.sel(sel[2:0]), .en(v[0]), .out(out[7:0]));
	decoder_3_8 decoder2 (.sel(sel[2:0]), .en(v[1]), .out(out[15:8]));
	decoder_3_8 decoder3 (.sel(sel[2:0]), .en(v[2]), .out(out[23:16]));
	decoder_3_8 decoder4 (.sel(sel[2:0]), .en(v[3]), .out(out[31:24]));
	
endmodule

// testbench for 5x32 decoder
module decoder_5_32_testbench();
	// repeats the variables as explained above
	logic [4:0] sel;
	logic [31:0] out;
	logic en;
	integer i;
	// initializes the mux2_1 module with the reference varibles
	decoder_5_32 dut (.sel, .en, .out);
	initial begin
		en = 1;
		for (i=0; i<32; i++) begin
			sel = i;
			#100;
		end 
		en = 0;
		for (i=0; i<32; i++) begin
			sel = i;
			#100;
		end 
	end
endmodule 