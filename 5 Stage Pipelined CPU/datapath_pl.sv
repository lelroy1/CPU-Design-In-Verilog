// Creates the logic and modules needed for a basic microcontroller datapath with pipelining
// Inputs: reg2loc, regwr, alusrc, addi, aluop, byteop, setflags, mov, memwr, mem2reg, movk, uncondbr,
// brtaken, cbz, blt, b
// Outputs: instruction, negative, negative_alu, overflow, overflow_alu,
// zero, zero_alu, carry_out, setflags_ex, blt_rf, b_rf

`timescale 1ns/10ps
module datapath(clk, reset, aluop, reg2loc, regwr, alusrc, addi, byteop, setflags,
                setzeroflag, mov, memwr, mem2reg, movk, uncondbr, brtaken, cbz, blt, b,
                instruction, negative, overflow, negative_alu, overflow_alu, zero, zero_alu, carry_out, setflags_ex, blt_rf, b_rf);
    input logic [2:0] aluop;
    input logic reg2loc, regwr, alusrc, addi, byteop, setflags, setzeroflag, mov, memwr, 
                mem2reg, movk, uncondbr, brtaken, cbz, blt, b;
    input logic clk, reset;
    output logic [31:0] instruction;
    output logic negative, overflow, negative_alu, overflow_alu, zero, zero_alu, carry_out;
    output logic setflags_ex, blt_rf, b_rf;

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

    // ALL LOGIC DEFINITIONS FOR FORWARDING

    // IF and RF latch signals
    logic [63:0] programcount_rf, branchtaken_countnext_rf;
    logic [4:0] Rd_rf, Rm_rf, Rn_rf;
    logic [18:0] imm19_rf;
    logic [15:0] imm16_rf;
    logic [11:0] imm12_rf;
    logic [8:0] imm9_rf; 
    logic [1:0] shamt_rf; 
    logic [2:0] aluop_rf; 
    logic reg2loc_rf, regwr_rf, alusrc_rf, addi_rf, byteop_rf, setflags_rf, setzeroflag_rf, mov_rf, memwr_rf, mem2reg_rf, movk_rf, cbz_rf, brtaken_rf;

    // computing accelerated branch
    logic [63:0] cb_accelerated;
    logic zero_accelerated;

    // RF and EX latch signals
    logic [63:0] ReadData1_ex, ReadData2_ex;
    logic [15:0] imm16_ex;
    logic [11:0] imm12_ex;
    logic [8:0] imm9_ex; 
    logic [4:0] Rd_ex;
    logic [1:0] shamt_ex; 
    logic [2:0] aluop_ex; 
    logic regwr_ex, alusrc_ex, addi_ex, byteop_ex, setzeroflag_ex, mov_ex, memwr_ex, mem2reg_ex, movk_ex;

    // EX Signals
    logic [63:0] alu_result;

    // EX forwarding
    logic rmrf_eq_rdex, rnrf_eq_rdex, rdrf_eq_rdex;

    // EX and MEM latch signals
    logic [63:0] ReadData2_mem;
    logic [63:0] alu_result_mem;
    logic [15:0] imm16_mem;
    logic [4:0] Rd_mem;
    logic [1:0] shamt_mem; 
    logic regwr_mem, byteop_mem, mov_mem, memwr_mem, mem2reg_mem, movk_mem;

    // MEM signals
    logic [63:0] WriteData_mem;
    
    // MEM forwarding
    logic rmrf_eq_rdmem, rnrf_eq_rdmem, rdrf_eq_rdmem;

    // MEM to WB latch signals
    logic [63:0] WriteData;
    logic [4:0] Rd_wb;
    logic regwr_wb;

    // start instruction fetch
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

    // if blt in RF then brtaken = negative_alu != overflow_alu
    // otherwise brtaken = negative != overflow 
    logic [63:0] programcountnext_brtaken;
    mux2_1_64 brtaken_mux (.out(programcountnext_brtaken), .i0(countnext), .i1(branchtaken_countnext_rf), .sel(brtaken));
    
    // mux that overrides the program count during cbz. should only override noops 
    logic take_cbz_accelerated;
    and #50 brtaken_and_cbz (take_cbz_accelerated, cbz_rf, zero_accelerated);
    mux2_1_64 cbz_override_mux (.out(programcountnext), .i0(programcountnext_brtaken), .i1(cb_accelerated), .sel(take_cbz_accelerated));
    // end instruction fetch

    // START LATCH BETWEEN IF AND RF
    // latch between instruction fetch and register fetch
    if_2_rf if_latch (.clk, .reset, .programcount, .Rd, .Rm, .Rn, .imm19, .imm16, .imm12, .imm9, .shamt, .aluop, .reg2loc, .regwr, .alusrc, .addi, .byteop, .setflags, .setzeroflag, .mov, .memwr, .mem2reg, .movk, .cbz, .blt, .b, .brtaken, .branchtaken_countnext,
            .programcount_dec(programcount_rf), .Rd_dec(Rd_rf), .Rm_dec(Rm_rf), .Rn_dec(Rn_rf), .imm19_dec(imm19_rf), .imm16_dec(imm16_rf), .imm12_dec(imm12_rf), .imm9_dec(imm9_rf), .shamt_dec(shamt_rf), .aluop_dec(aluop_rf), .reg2loc_dec(reg2loc_rf),
            .regwr_dec(regwr_rf), .alusrc_dec(alusrc_rf), .addi_dec(addi_rf), .byteop_dec(byteop_rf), .setflags_dec(setflags_rf), .setzeroflag_dec(setzeroflag_rf), .mov_dec(mov_rf),
            .memwr_dec(memwr_rf), .mem2reg_dec(mem2reg_rf), .movk_dec(movk_rf), .cbz_dec(cbz_rf), .blt_dec(blt_rf), .b_dec(b_rf), .brtaken_dec(brtaken_rf), .branchtaken_countnext_dec(branchtaken_countnext_rf));
    // END LATCH BETWEEN IF AND RF

    // start register fetch
    logic [4:0] ReadRegister2;
    logic [63:0] ReadData1_reg, ReadData2_reg;
    logic [63:0] ReadData1_forward1, ReadData2_forward1, ReadData2_forward2, ReadData2_forward3;
    logic [63:0] ReadData1, ReadData2;

    mux2_1_5 regfilein_mux (.out(ReadRegister2), .i0(Rm_rf), .i1(Rd_rf), .sel(reg2loc_rf)); // regfile input mux

    logic clk_n;
    not #50 clk_invert (clk_n, clk);
    regfile regfilemodule (.ReadData1(ReadData1_reg), .ReadData2(ReadData2_reg), .WriteData, .ReadRegister1(Rn_rf), .ReadRegister2, .WriteRegister(Rd_wb), .RegWrite(regwr_wb), .clk(clk_n));

    // FORWARDING FROM EXEC
    logic rn_temp_and, rn_eq_31, rn_not_eq_31;
    and #50 rn_ne_31 (rn_temp_and, Rn_rf[0], Rn_rf[1], Rn_rf[2], Rn_rf[3]);
    and #50 rn_ne_31a (rn_eq_31, rn_temp_and, Rn_rf[4]);
    not #50 rn_ne_31_fin (rn_not_eq_31, rn_eq_31);

    logic rm_temp_and, rm_eq_31, rm_not_eq_31;
    and #50 rm_ne_31 (rm_temp_and, Rm_rf[0], Rm_rf[1], Rm_rf[2], Rm_rf[3]);
    and #50 rm_ne_31a (rm_eq_31, rm_temp_and, Rm_rf[4]);
    not #50 rm_ne_31_fin (rm_not_eq_31, rm_eq_31);

    logic rd_temp_and, rd_eq_31, rd_not_eq_31;
    and #50 rd_ne_31 (rd_temp_and, Rd_rf[0], Rd_rf[1], Rd_rf[2], Rd_rf[3]);
    and #50 rd_ne_31a (rd_eq_31, rd_temp_and, Rd_rf[4]);
    not #50 rd_ne_31_fin (rd_not_eq_31, rd_eq_31);

    logic rn_forward_ex, rm_forward_ex, rd_forward_ex;

    // to override Rn
    // if (we are writing to reg in ex) and (rn rf == rd ex) and (rn rf is not X31)
    and #50 rn_forward_and_ex (rn_forward_ex, regwr_ex, rnrf_eq_rdex, rn_not_eq_31);
    mux2_1_64 readdata1mux_ex (.out(ReadData1_forward1), .i0(ReadData1_reg), .i1(alu_result), .sel(rn_forward_ex));

    // to override Rm
    // if (we are writing to reg in ex) and (rm rf == rd ex) and (rm rf is not X31)
    and #50 rm_forward_and_ex (rm_forward_ex, regwr_ex, rmrf_eq_rdex, rm_not_eq_31);
    mux2_1_64 readdata2mux_ex (.out(ReadData2_forward1), .i0(ReadData2_reg), .i1(alu_result), .sel(rm_forward_ex));

    // to override CBZ register
    // if (we are writing to reg in ex) and (Rd rf == Rd ex) and (Rd rf is being used as operand) and (Rd rf is not X31)
    and #50 rd_forward_and_ex (rd_forward_ex, regwr_ex, rdrf_eq_rdex, reg2loc_rf, rd_not_eq_31);
    mux2_1_64 readdata2mux_rd_ex (.out(ReadData2_forward2), .i0(ReadData2_forward1), .i1(alu_result), .sel(rd_forward_ex));

    // FORWARDING FROM MEM
    logic rn_forward_mem, rm_forward_mem, rd_forward_mem;

    // to override Rn
    // This says (Rn in Rf == Rd in mem) + (we did not forward ex first) + (we are writing) + (rn is not 31)
    logic not_rn_forward_ex;
    not #50 (not_rn_forward_ex, rn_forward_ex);
    and #50 rn_forward_and_mem (rn_forward_mem, rnrf_eq_rdmem, not_rn_forward_ex, regwr_mem, rn_not_eq_31);
    mux2_1_64 readdata1mux_mem (.out(ReadData1), .i0(ReadData1_forward1), .i1(WriteData_mem), .sel(rn_forward_mem));

    // to override Rm
    // cycle 36 needs to override readdata
    //and #50 rm_forward_and_mem (rm_forward_mem, rmrf_eq_rdmem, regwr_mem, rm_not_eq_31);
    logic not_rm_forward_ex;
    not #50 (not_rm_forward_ex, rm_forward_ex);
    and #50 rm_forward_and_mem (rm_forward_mem, rmrf_eq_rdmem, not_rm_forward_ex, regwr_mem, rm_not_eq_31);
    mux2_1_64 readdata2mux_mem (.out(ReadData2_forward3), .i0(ReadData2_forward2), .i1(WriteData_mem), .sel(rm_forward_mem));

    // to override CBZ register
    // This says (Rd Rf == Rd in mem) + (we are not forwarding from ex) + (we are writing) + (Rd rf is an operand) + (rd is not 31)
    logic not_rd_forward_ex;
    not #50 (not_rd_forward_ex, rd_forward_ex);
    and #50 rd_forward_and_mem (rd_forward_mem, not_rd_forward_ex, rdrf_eq_rdmem, regwr_mem, reg2loc_rf, rd_not_eq_31);
    mux2_1_64 readdata3mux_mem (.out(ReadData2), .i0(ReadData2_forward3), .i1(WriteData_mem), .sel(rd_forward_mem));

    // CBZ ACCELERATED BRANCH:
    logic [63:0] imm19_rf_se, imm19_rf_lsl2;
    signextend19 s0_accelerated (.imm19(imm19_rf), .out(imm19_rf_se));
    lsl2 shift2_acc (.in(imm19_rf_se), .out(imm19_rf_lsl2));
    bitadder64 advanced_calc_cb (.a(programcount_rf), .b(imm19_rf_lsl2), .out(cb_accelerated));
    // compute CBZ condition
    logic [15:0] first_nors;
    genvar j;
    generate
    	for(j=0; j<64; j=j+4) begin : nor_connections	
            nor #50 first_layer (first_nors[j/4], ReadData2[j], ReadData2[j+1], ReadData2[j+2], ReadData2[j+3]);
    	end
    endgenerate
    
    logic [3:0] second_nors;
    and #50 second_layer0 (second_nors[0], first_nors[0], first_nors[1], first_nors[2], first_nors[3]);
    and #50 second_layer1 (second_nors[1], first_nors[4], first_nors[5], first_nors[6], first_nors[7]);
    and #50 second_layer2 (second_nors[2], first_nors[8], first_nors[9], first_nors[10], first_nors[11]);
    and #50 second_layer3 (second_nors[3], first_nors[12], first_nors[13], first_nors[14], first_nors[15]);  

    and #50 last_and (zero_accelerated, second_nors[0], second_nors[1], second_nors[2], second_nors[3]);


    // START LATCH BETWEEN RF AND EX
    rf_2_exec rf_latch (.clk, .reset, .ReadData1, .ReadData2, .Rd(Rd_rf), .imm16(imm16_rf), .imm12(imm12_rf), .imm9(imm9_rf), .shamt(shamt_rf), .aluop(aluop_rf), .regwr(regwr_rf), .alusrc(alusrc_rf),
                        .addi(addi_rf), .byteop(byteop_rf), .setflags(setflags_rf), .setzeroflag(setzeroflag_rf), .mov(mov_rf), .memwr(memwr_rf), .mem2reg(mem2reg_rf), .movk(movk_rf), 
                        .ReadData1_dec(ReadData1_ex), .ReadData2_dec(ReadData2_ex), .Rd_dec(Rd_ex), .imm16_dec(imm16_ex), .imm12_dec(imm12_ex), .imm9_dec(imm9_ex), .shamt_dec(shamt_ex), .aluop_dec(aluop_ex),
                        .regwr_dec(regwr_ex), .alusrc_dec(alusrc_ex), .addi_dec(addi_ex), .byteop_dec(byteop_ex), .setflags_dec(setflags_ex), .setzeroflag_dec(setzeroflag_ex), .mov_dec(mov_ex),
                        .memwr_dec(memwr_ex), .mem2reg_dec(mem2reg_ex), .movk_dec(movk_ex));
    // END LATCH BETWEEN RF AND EX

    // start execute
    logic [63:0] imm9_se;
    signextend9 s1 (.imm9(imm9_ex), .out(imm9_se));

    logic [63:0] alusrc_mux_out;
    mux2_1_64 alusrc_mux (.out(alusrc_mux_out), .i0(imm9_se) ,.i1(ReadData2_ex), .sel(alusrc_ex));

    logic [63:0] imm12_ze;
    zeroextend12 s2 (.imm12(imm12_ex), .out(imm12_ze));

    logic [63:0] addi_mux_out;
    mux2_1_64 addi_mux (.out(addi_mux_out), .i0(alusrc_mux_out) ,.i1(imm12_ze), .sel(addi_ex));

    logic [63:0] alu_result_direct;
    logic carry_out_alu;
    alu alu_computes (.A(ReadData1_ex), .B(addi_mux_out), .cntrl(aluop_ex), .result(alu_result_direct), .zero(zero_alu), 
                      .overflow(overflow_alu), .carry_out(carry_out_alu), .negative(negative_alu));

    logic negative_next, overflow_next, carry_out_next, zero_next;
    D_FF negativeff (.d(negative_next), .reset, .clk, .q(negative));
    D_FF overflowff (.d(overflow_next), .reset, .clk, .q(overflow));
    D_FF carry_outff (.d(carry_out_next), .reset, .clk, .q(carry_out));
    D_FF zero_ff (.d(zero_next), .reset, .clk, .q(zero));

    mux2_1 negative_mux (.out(negative_next), .i0(negative), .i1(negative_alu), .sel(setflags_ex));
    mux2_1 overflow_mux (.out(overflow_next), .i0(overflow), .i1(overflow_alu), .sel(setflags_ex));
    mux2_1 carry_out_mux (.out(carry_out_next), .i0(carry_out), .i1(carry_out_alu), .sel(setflags_ex));

    logic setzero;
    or #50 setzero_or (setzero, setflags_ex, setzeroflag_ex);
    mux2_1 zero_mux (.out(zero_next), .i0(zero), .i1(zero_alu), .sel(setzero));
    
    // Start the forwarding logic for RF when overriding a register
    // if regwr then do forwarding if register is not 31 should send
    // send to RF only. Have some way to check that the source register
    // is equal to one of the operating registers in RF
    // if(regwr_ex):
    //   if (Rm_rf == Rd_ex)
    //      override ReadData1 or ReadData2 
    //   if (Rn_rf == Rd_ex)
    //      override ReadData1 or ReadData2 

    logic [4:0] rm_and_result;
    genvar i;
	generate
		for(i=0; i<5; i++) begin : eachAnd1
            // test that each bit in Rm rf and Rd ex are equal
			xnor #50 rm_eq_rf (rm_and_result[i], Rm_rf[i], Rd_ex[i]);
		end
	endgenerate
    logic rm_and_result2;
    and #50 rm_eq_rf2 (rm_and_result2, rm_and_result[0], rm_and_result[1], rm_and_result[2], rm_and_result[3]);
    and #50 rm_eq_rf2_fin (rmrf_eq_rdex, rm_and_result2, rm_and_result[4]);

    logic [4:0] rn_and_result;
    genvar l;
	generate
		for(l=0; l<5; l++) begin : eachAnd2
            // test that each bit in Rn rf and Rd ex are equal
			xnor #50 rn_eq_rf (rn_and_result[l], Rn_rf[l], Rd_ex[l]);
		end
	endgenerate
    logic rn_and_result2;
    and #50 rn_eq_rf2 (rn_and_result2, rn_and_result[0], rn_and_result[1], rn_and_result[2], rn_and_result[3]);
    and #50 rn_eq_rf2_fin (rnrf_eq_rdex, rn_and_result2, rn_and_result[4]);

    logic [4:0] rd_and_result;
    genvar k;
	generate
		for(k=0; k<5; k++) begin : eachAnd31
            // test that each bit in Rd rf and Rd ex are equal
			xnor #50 rd_eq_rf (rd_and_result[k], Rd_rf[k], Rd_ex[k]);
		end
	endgenerate
    logic rd_and_result2;
    and #50 rd_eq_rf2 (rd_and_result2, rd_and_result[0], rd_and_result[1], rd_and_result[2], rd_and_result[3]);
    and #50 rd_eq_rf2_fin (rdrf_eq_rdex, rd_and_result2, rd_and_result[4]);

    logic [63:0] mov_out;
    mov movlogic (.movk(movk_ex), .shamt(shamt_ex), .imm16(imm16_ex), .reg_data(alu_result_direct), .result(mov_out));
    mux2_1_64 movmux (.out(alu_result), .i0(alu_result_direct), .i1(mov_out), .sel(mov_ex));

    // end execute 

    // START LATCH BETWEEN EX AND MEM 
    exec_2_mem exec_latch (.clk, .reset, .ReadData2(ReadData2_ex), .Rd(Rd_ex), .alu_result, .imm16(imm16_ex), .shamt(shamt_ex), .regwr(regwr_ex), .byteop(byteop_ex), .mov(mov_ex), .memwr(memwr_ex), 
                           .mem2reg(mem2reg_ex), .movk(movk_ex), .ReadData2_dec(ReadData2_mem), .Rd_dec(Rd_mem), .alu_result_dec(alu_result_mem), .imm16_dec(imm16_mem), .shamt_dec(shamt_mem),
                           .regwr_dec(regwr_mem), .byteop_dec(byteop_mem), .mov_dec(mov_mem), .memwr_dec(memwr_mem), .mem2reg_dec(mem2reg_mem), .movk_dec(movk_mem));
    // END LATCH BETWEEN EX AND MEM 

    // begin data memory
    logic [63:0] mem_write_data, mem_read_data;
    logic [3:0] xfer_size;
    //logic mem_write_enable;

    mux2_1_64 sturbyte_mux(.out(mem_write_data), .i0(ReadData2_mem), .i1({{56{1'b0}}, ReadData2_mem[7:0]}), .sel(byteop_mem));

    mux2_1_4 xfer_mux (.out(xfer_size), .i0(4'b1000), .i1(4'b0001), .sel(byteop_mem));

    datamem mainmemory (.address(alu_result_mem), .write_enable(memwr_mem), .read_enable(1'b1),
                        .write_data(mem_write_data), .clk, .xfer_size, .read_data(mem_read_data));
    logic [63:0] mem2reg_mux_out;
    mux2_1_64 mem2reg_mux(.out(mem2reg_mux_out), .i0(alu_result_mem), .i1(mem_read_data), .sel(mem2reg_mem));

    //logic [63:0] ldurbyte_mux_out;
    //mux2_1_64 ldurbyte_mux(.out(ldurbyte_mux_out), .i0(mem2reg_mux_out), .i1({{56{1'b0}}, mem2reg_mux_out[7:0]}), .sel(byteop_mem)); 
    mux2_1_64 ldurbyte_mux(.out(WriteData_mem), .i0(mem2reg_mux_out), .i1({{56{1'b0}}, mem2reg_mux_out[7:0]}), .sel(byteop_mem)); 

    // need to move to aluresult in EX
    //logic [63:0] mov_out;
    //mov movlogic (.movk(movk_mem), .shamt(shamt_mem), .imm16(imm16_mem), .reg_data(ReadData2_mem), .result(mov_out));
    //mux2_1_64 movmux (.out(WriteData_mem), .i0(ldurbyte_mux_out), .i1(mov_out), .sel(mov_mem));

    // FORWARDING FROM MEM TO RF
    logic [4:0] rm_and_result1;
    genvar i1;
	generate
		for(i1=0; i1<5; i1++) begin : eachAnd3
            // test that each bit in Rm and Rd are equal
			xnor #50 rm_eq_mem (rm_and_result1[i1], Rm_rf[i1], Rd_mem[i1]);
		end
	endgenerate
    logic rm_and_result_mem;
    and #50 rmmem_eq_rf2 (rm_and_result_mem, rm_and_result1[0], rm_and_result1[1], rm_and_result1[2], rm_and_result1[3]);
    and #50 rmmem_eq_rf2_fin (rmrf_eq_rdmem, rm_and_result_mem, rm_and_result1[4]);

    logic [4:0] rn_and_result1;
    genvar j1;
	generate
		for(j1=0; j1<5; j1++) begin : eachAnd4
            // test that each bit in Rn and Rd are equal
			xnor #50 rn_eq_mem (rn_and_result1[j1], Rn_rf[j1], Rd_mem[j1]);
		end
	endgenerate
    logic rn_and_result_mem;
    and #50 rnmem_eq_rf2 (rn_and_result_mem, rn_and_result1[0], rn_and_result1[1], rn_and_result1[2], rn_and_result1[3]);
    and #50 rnmem_eq_rf2_fin (rnrf_eq_rdmem, rn_and_result_mem, rn_and_result1[4]);

    logic [4:0] rd_and_result1;
    genvar k1;
	generate
		for(k1=0; k1<5; k1++) begin : eachAnd5
            // test that each bit in Rd mem and Rd rf are equal
			xnor #50 rd_eq_mem (rd_and_result1[k1], Rd_rf[k1], Rd_mem[k1]);
		end
	endgenerate
    logic rd_and_result_mem;
    and #50 rdmem_eq_rf2 (rd_and_result_mem, rd_and_result1[0], rd_and_result1[1], rd_and_result1[2], rd_and_result1[3]);
    and #50 rdmem_eq_rf2_fin (rdrf_eq_rdmem, rd_and_result_mem, rd_and_result1[4]);
    // end data memory

    // START LATCH BETWEEN MEM AND WB 

    mem_2_wb mem_latch (.clk, .reset, .Rd(Rd_mem), .regwr(regwr_mem), .WriteData(WriteData_mem), .Rd_dec(Rd_wb),
                        .WriteData_dec(WriteData), .regwr_dec(regwr_wb));
    // END LATCH BETWEEN MEM AND WB 

    /* signals to send back to rf 
    WriteData, regwr_wb, Rd
    */
    
endmodule
