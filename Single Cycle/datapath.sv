// Creates the logic and modules needed for a basic microcontroller datapath
// Inputs: Rd, Rm, Rn, reg2loc, regwr, imm9, imm12, imm16, imm19, imm26, alusrc,
// addi, aluop, byteop, setflags, mov, memwr, mem2reg, movk, shamt, uncondbr,
// brtaken
// Outputs: instruction, negative, overflow, zero, zero_alu, carry_out

`timescale 1ns/10ps
module datapath(clk, reset, aluop, reg2loc, regwr, alusrc, addi, byteop, setflags,
                setzeroflag, mov, memwr, mem2reg, movk, uncondbr, brtaken,
                instruction, negative, overflow, zero, zero_alu, carry_out);
    input logic [2:0] aluop;
    input logic reg2loc, regwr, alusrc, addi, byteop, setflags, setzeroflag, mov, memwr, 
                mem2reg, movk, uncondbr, brtaken;
    input logic clk, reset;
    output logic [31:0] instruction;
    output logic negative, overflow, zero, zero_alu, carry_out;

    // assign opcode bits to internal registers
    logic [25:0] imm26;
    logic [18:0] imm19;
    logic [15:0] imm16;
    logic [11:0] imm12;
    logic [8:0] imm9;
    logic [1:0] shamt;
    logic [4:0] Rd, Rm, Rn;

    assign imm26 = instruction[25:0];
    assign imm19 = instruction[23:5];
    assign imm16 = instruction[21:5];
    assign shamt = instruction[22:21];
    assign imm12 = instruction[21:10];
    assign imm9 = instruction[20:12];
    assign Rd = instruction[4:0];
    assign Rm = instruction[20:16];
    assign Rn = instruction[9:5];


    // start connections for program counter
    logic [63:0] programcountnext, programcountnext_reset, programcount; 
    mux2_1_64 pcresetmux (.out(programcountnext_reset), .i0(programcountnext), .i1(64'd0), .sel(reset));
    register programcounter (.d(programcountnext_reset), .wren(1'b1), .clk, .q(programcount));
 
    instructmem instmem (.address(programcount), .instruction, .clk);

    logic [63:0] imm19_se, imm26_se;
    signextend19 s0 (.imm19, .out(imm19_se));
    signextend26 s01 (.imm26, .out(imm26_se));

    logic [63:0] branch_mux;
    mux2_1_64 brmux (.out(branch_mux), .i0(imm19_se), .i1(imm26_se), .sel(uncondbr));
    
    logic [63:0] shifted_branch;
    lsl2 shift2 (.in(branch_mux), .out(shifted_branch));

    logic [63:0] branchtaken_countnext, countnext;
    bitadder64 addpcbranch (.a(shifted_branch), .b(programcount), .out(branchtaken_countnext));
    bitadder64 addpc4 (.a(64'd4), .b(programcount), .out(countnext));

    mux2_1_64 brtaken_mux (.out(programcountnext), .i0(countnext), .i1(branchtaken_countnext), .sel(brtaken));

    // start connections for main datapath
    logic [4:0] ReadRegister2;
    logic [63:0] ReadData1, ReadData2, WriteData;

    mux2_1_5 regfilein_mux (.out(ReadRegister2), .i0(Rm), .i1(Rd), .sel(reg2loc)); // regfile input mux

    regfile regfilemodule (.ReadData1, .ReadData2, .WriteData, .ReadRegister1(Rn), .ReadRegister2, .WriteRegister(Rd), .RegWrite(regwr), .clk);

    logic [63:0] imm9_se;
    signextend9 s1 (.imm9, .out(imm9_se));

    logic [63:0] alusrc_mux_out;
    mux2_1_64 alusrc_mux (.out(alusrc_mux_out), .i0(imm9_se) ,.i1(ReadData2), .sel(alusrc));

    logic [63:0] imm12_ze;
    zeroextend12 s2 (.imm12, .out(imm12_ze));

    logic [63:0] addi_mux_out;
    mux2_1_64 addi_mux (.out(addi_mux_out), .i0(alusrc_mux_out) ,.i1(imm12_ze), .sel(addi));

    logic [63:0] alu_result;
    logic overflow_alu, carry_out_alu, negative_alu;
    alu alu_computes (.A(ReadData1), .B(addi_mux_out), .cntrl(aluop), .result(alu_result), .zero(zero_alu), 
                      .overflow(overflow_alu), .carry_out(carry_out_alu), .negative(negative_alu));

    logic negative_next, overflow_next, carry_out_next, zero_next;
    D_FF negativeff (.d(negative_next), .reset, .clk, .q(negative));
    D_FF overflowff (.d(overflow_next), .reset, .clk, .q(overflow));
    D_FF carry_outff (.d(carry_out_next), .reset, .clk, .q(carry_out));
    D_FF zero_ff (.d(zero_next), .reset, .clk, .q(zero));

    mux2_1 negative_mux (.out(negative_next), .i0(negative), .i1(negative_alu), .sel(setflags));
    mux2_1 overflow_mux (.out(overflow_next), .i0(overflow), .i1(overflow_alu), .sel(setflags));
    mux2_1 carry_out_mux (.out(carry_out_next), .i0(carry_out), .i1(carry_out_alu), .sel(setflags));

    logic setzero;
    or #50 setzero_or (setzero, setflags, setzeroflag);
    mux2_1 zero_mux (.out(zero_next), .i0(zero), .i1(zero_alu), .sel(setzero));

    // initialize the signals for main memory and main memory module
    logic [63:0] mem_write_data, mem_read_data;
    logic [3:0] xfer_size;
    logic mem_write_enable;

    mux2_1_64 sturbyte_mux(.out(mem_write_data), .i0(ReadData2), .i1({{56{1'b0}}, ReadData2[7:0]}), .sel(byteop));

    mux2_1_4 xfer_mux (.out(xfer_size), .i0(4'b1000), .i1(4'b0001), .sel(byteop));

    datamem mainmemory (.address(alu_result), .write_enable(memwr), .read_enable(1'b1),
                        .write_data(mem_write_data), .clk, .xfer_size, .read_data(mem_read_data));

    logic [63:0] mem2reg_mux_out;
    mux2_1_64 mem2reg_mux(.out(mem2reg_mux_out), .i0(alu_result), .i1(mem_read_data), .sel(mem2reg));

    logic [63:0] ldurbyte_mux_out;
    mux2_1_64 ldurbyte_mux(.out(ldurbyte_mux_out), .i0(mem2reg_mux_out), .i1({{56{1'b0}}, mem2reg_mux_out[7:0]}), .sel(byteop)); 

    logic [63:0] mov_out;
    mov movlogic (.movk, .shamt, .imm16, .reg_data(ReadData2), .result(mov_out));

    mux2_1_64 movmux (.out(WriteData), .i0(ldurbyte_mux_out), .i1(mov_out), .sel(mov));
    
endmodule