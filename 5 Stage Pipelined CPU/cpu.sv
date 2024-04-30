// top level module for the single cycle CPU. Instruction ARM files are loaded by changing the file
// referenced in instructmem.sv

`timescale 1ns/10ps
module cpu(reset, clk);
      input logic clk, reset;

      logic reg2loc, regwr, alusrc, addi, byteop, setflags, setflags_ex, setzeroflag, mov, memwr, 
            mem2reg, movk, uncondbr, brtaken, cbz;
      logic [2:0] aluop;
      logic [31:0] instruction;
      logic negative, overflow, negative_alu, overflow_alu, zero, zero_alu, carry_out, blt, blt_rf, b, b_rf;


      controller control (.instruction, .negative, .overflow, .negative_alu, .overflow_alu, .zero, .zero_alu, .carry_out,  .aluop, .blt_rf, .reg2loc, .regwr, .alusrc,
                          .addi, .byteop, .setflags, .setflags_ex, .setzeroflag, .mov, .memwr, .mem2reg, .movk, .uncondbr, .brtaken, .cbz, .blt, .b, .b_rf);
      datapath path (.clk, .reset, .aluop, .reg2loc, .regwr, .alusrc, .addi, .byteop, .setflags, .setflags_ex, .setzeroflag,
                     .mov, .memwr, .mem2reg, .movk, .uncondbr, .brtaken, .cbz, .instruction, .negative, .overflow, .zero, .negative_alu, .overflow_alu, .zero_alu, .carry_out, .blt, .blt_rf, .b, .b_rf);
endmodule

// testbench for the single cycle cpu
module cpu_tb();
      logic reset, clk;

      cpu dut (.reset, .clk);

      initial begin // Set up the clock
		clk <= 0;
		forever #(50000/2) clk <= ~clk;
	end

	integer i;
	initial begin
		reset <= 1; @(posedge clk);
		reset <= 0; @(posedge clk);
					@(posedge clk);
		for (i=0; i<400; i++) begin
			@(posedge clk);
		end
		$stop;
	end
endmodule