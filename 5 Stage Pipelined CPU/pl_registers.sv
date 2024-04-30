`timescale 1ns/10ps
// This file will be used to defined the registers between the different stages

    /* signals to latch:
    Rd, Rm, Rn
    imm16, imm12, imm9
    shamt
    aluop, reg2loc, regwr, alusrc, addi, byteop, setflags, setzeroflag, mov, memwr, mem2reg, movk;
    */


module if_2_rf(clk, reset, programcount, Rd, Rm, Rn, imm19, imm16, imm12, imm9, shamt, aluop, reg2loc, regwr, alusrc, addi, byteop, setflags, setzeroflag, mov, memwr, mem2reg, movk, cbz, blt, b, brtaken, branchtaken_countnext,
                programcount_dec, Rd_dec, Rm_dec, Rn_dec, imm19_dec, imm16_dec, imm12_dec, imm9_dec, shamt_dec, aluop_dec, reg2loc_dec, regwr_dec, alusrc_dec, addi_dec, byteop_dec, setflags_dec, setzeroflag_dec, mov_dec, memwr_dec, mem2reg_dec, movk_dec, cbz_dec, blt_dec, b_dec, brtaken_dec, branchtaken_countnext_dec);
      input logic clk, reset;

      input logic [63:0] programcount;
      input logic [63:0] branchtaken_countnext;
      input logic [4:0] Rd, Rm, Rn;
      input logic [18:0] imm19;
      input logic [15:0] imm16;
      input logic [11:0] imm12;
      input logic [8:0] imm9; 
      input logic [1:0] shamt; 
      input logic [2:0] aluop; 
      input logic reg2loc, regwr, alusrc, addi, byteop, setflags, setzeroflag, mov, memwr, mem2reg, movk, cbz, blt, b, brtaken;

      output logic [63:0] programcount_dec;
      output logic [63:0] branchtaken_countnext_dec;
      output logic [4:0] Rd_dec, Rm_dec, Rn_dec;
      output logic [18:0] imm19_dec;
      output logic [15:0] imm16_dec;
      output logic [11:0] imm12_dec;
      output logic [8:0] imm9_dec; 
      output logic [1:0] shamt_dec; 
      output logic [2:0] aluop_dec; 
      output logic reg2loc_dec, regwr_dec, alusrc_dec, addi_dec, byteop_dec, setflags_dec, setzeroflag_dec, mov_dec, memwr_dec, mem2reg_dec, movk_dec, cbz_dec, blt_dec, b_dec, brtaken_dec;

      register_64 programcount_pl (.q(programcount_dec), .d(programcount), .reset, .clk);
      register_64 brtaken_count_pl (.q(branchtaken_countnext_dec), .d(branchtaken_countnext), .reset, .clk);
      
      register_5 rd_pl (.q(Rd_dec), .d(Rd), .reset, .clk);
      register_5 rm_pl (.q(Rm_dec), .d(Rm), .reset, .clk);
      register_5 rn_pl (.q(Rn_dec), .d(Rn), .reset, .clk);

      register_19 imm19_pl (.q(imm19_dec), .d(imm19), .reset, .clk);

      register_16 imm16_pl (.q(imm16_dec), .d(imm16), .reset, .clk);

      register_12 imm12_pl (.q(imm12_dec), .d(imm12), .reset, .clk);

      register_9 imm9_pl (.q(imm9_dec), .d(imm9), .reset, .clk);

      register_2 shamt_pl (.q(shamt_dec), .d(shamt), .reset, .clk);

      register_3 aluop_pl (.q(aluop_dec), .d(aluop), .reset, .clk);

      D_FF reg2log_pl (.q(reg2loc_dec), .d(reg2loc), .reset, .clk);
      D_FF regwr_pl (.q(regwr_dec), .d(regwr), .reset, .clk);
      D_FF alusrc_pl (.q(alusrc_dec), .d(alusrc), .reset, .clk);
      D_FF addi_pl (.q(addi_dec), .d(addi), .reset, .clk);
      D_FF byteop_pl (.q(byteop_dec), .d(byteop), .reset, .clk);
      D_FF setflags_pl (.q(setflags_dec), .d(setflags), .reset, .clk);
      D_FF setzeroflag_pl (.q(setzeroflag_dec), .d(setzeroflag), .reset, .clk);
      D_FF mov_pl (.q(mov_dec), .d(mov), .reset, .clk);
      D_FF memwr_pl (.q(memwr_dec), .d(memwr), .reset, .clk);
      D_FF mem2reg_pl (.q(mem2reg_dec), .d(mem2reg), .reset, .clk);
      D_FF movk_pl (.q(movk_dec), .d(movk), .reset, .clk);
      D_FF cbz_pl (.q(cbz_dec), .d(cbz), .reset, .clk);
      D_FF brtaken_pl (.q(brtaken_dec), .d(brtaken), .reset, .clk);
      D_FF blt_pl (.q(blt_dec), .d(blt), .reset, .clk);
      D_FF b_pl (.q(b_dec), .d(b), .reset, .clk);
endmodule

    /* signals to latch:
    ReadData1, ReadData2
    Rd
    imm16, imm12, imm9
    shamt
    aluop, regwr, alusrc, addi, byteop, setflags, setzeroflag, mov, memwr, mem2reg, movk;
    */

module rf_2_exec (clk, reset, ReadData1, ReadData2, Rd, imm16, imm12, imm9, shamt, aluop, regwr, alusrc, addi, byteop, setflags, setzeroflag, mov, memwr, mem2reg, movk,
                  ReadData1_dec, ReadData2_dec, Rd_dec, imm16_dec, imm12_dec, imm9_dec, shamt_dec, aluop_dec, regwr_dec, alusrc_dec, addi_dec, byteop_dec, setflags_dec, setzeroflag_dec, mov_dec, memwr_dec, mem2reg_dec, movk_dec);

      input logic clk, reset;

      input logic [63:0] ReadData1, ReadData2;
      input logic [15:0] imm16;
      input logic [11:0] imm12;
      input logic [8:0] imm9; 
      input logic [4:0] Rd;
      input logic [1:0] shamt; 
      input logic [2:0] aluop; 
      input logic regwr, alusrc, addi, byteop, setflags, setzeroflag, mov, memwr, mem2reg, movk;

      output logic [63:0] ReadData1_dec, ReadData2_dec;
      output logic [15:0] imm16_dec;
      output logic [11:0] imm12_dec;
      output logic [8:0] imm9_dec; 
      output logic [4:0] Rd_dec;
      output logic [1:0] shamt_dec; 
      output logic [2:0] aluop_dec; 
      output logic regwr_dec, alusrc_dec, addi_dec, byteop_dec, setflags_dec, setzeroflag_dec, mov_dec, memwr_dec, mem2reg_dec, movk_dec;

      register_64 readdata1_pl (.q(ReadData1_dec), .d(ReadData1), .reset, .clk);

      register_64 readdata2_pl (.q(ReadData2_dec), .d(ReadData2), .reset, .clk);

      register_16 imm16_pl (.q(imm16_dec), .d(imm16), .reset, .clk);

      register_12 imm12_pl (.q(imm12_dec), .d(imm12), .reset, .clk);

      register_9 imm9_pl (.q(imm9_dec), .d(imm9), .reset, .clk);

      register_5 Rd_pl (.q(Rd_dec), .d(Rd), .reset, .clk);

      register_2 shamt_pl (.q(shamt_dec), .d(shamt), .reset, .clk);

      register_3 aluop_pl (.q(aluop_dec), .d(aluop), .reset, .clk);

      D_FF regwr_pl (.q(regwr_dec), .d(regwr), .reset, .clk);
      D_FF alusrc_pl (.q(alusrc_dec), .d(alusrc), .reset, .clk);
      D_FF addi_pl (.q(addi_dec), .d(addi), .reset, .clk);
      D_FF byteop_pl (.q(byteop_dec), .d(byteop), .reset, .clk);
      D_FF setflags_pl (.q(setflags_dec), .d(setflags), .reset, .clk);
      D_FF setzeroflag_pl (.q(setzeroflag_dec), .d(setzeroflag), .reset, .clk);
      D_FF mov_pl (.q(mov_dec), .d(mov), .reset, .clk);
      D_FF memwr_pl (.q(memwr_dec), .d(memwr), .reset, .clk);
      D_FF mem2reg_pl (.q(mem2reg_dec), .d(mem2reg), .reset, .clk);
      D_FF movk_pl (.q(movk_dec), .d(movk), .reset, .clk);
endmodule

    /* signals to latch:
    ReadData2
    alu_result
    imm16
    shamt
    Rd
    regwr, byteop, mov, memwr, mem2reg, movk;
    */
module exec_2_mem (clk, reset, ReadData2, Rd, alu_result, imm16, shamt, regwr, byteop, mov, memwr, mem2reg, movk,
                   ReadData2_dec, Rd_dec, alu_result_dec, imm16_dec, shamt_dec, regwr_dec, byteop_dec, mov_dec, memwr_dec, mem2reg_dec, movk_dec);

      input logic clk, reset;
      
      input logic [63:0] ReadData2;
      input logic [63:0] alu_result;
      input logic [15:0] imm16;
      input logic [4:0] Rd; 
      input logic [1:0] shamt; 
      input logic regwr, byteop, mov, memwr, mem2reg, movk;

      output logic [63:0] ReadData2_dec;
      output logic [63:0] alu_result_dec;
      output logic [15:0] imm16_dec;
      output logic [4:0] Rd_dec;
      output logic [1:0] shamt_dec; 
      output logic regwr_dec, byteop_dec, mov_dec, memwr_dec, mem2reg_dec, movk_dec;

      register_64 readdata2_pl (.q(ReadData2_dec), .d(ReadData2), .reset, .clk);
      register_64 aluresult_pl (.q(alu_result_dec), .d(alu_result), .reset, .clk);

      register_16 imm16_pl (.q(imm16_dec), .d(imm16), .reset, .clk);

      register_5 Rd_pl (.q(Rd_dec), .d(Rd), .reset, .clk);

      register_2 shamt_pl (.q(shamt_dec), .d(shamt), .reset, .clk);

      D_FF regwr_pl (.q(regwr_dec), .d(regwr), .reset, .clk);
      D_FF byteop_pl (.q(byteop_dec), .d(byteop), .reset, .clk);
      D_FF mov_pl (.q(mov_dec), .d(mov), .reset, .clk);
      D_FF memwr_pl (.q(memwr_dec), .d(memwr), .reset, .clk);
      D_FF mem2reg_pl (.q(mem2reg_dec), .d(mem2reg), .reset, .clk);
      D_FF movk_pl (.q(movk_dec), .d(movk), .reset, .clk);
endmodule

    /* signals to latch:
    mov_out
    mov
    ldurbyte_mux_out
    regwr
    */ 

module mem_2_wb (clk, reset, Rd, regwr, WriteData, Rd_dec, regwr_dec, WriteData_dec);

      input logic clk, reset;

      input logic regwr;
      input logic [63:0] WriteData ;
      input logic [4:0] Rd;

      output logic regwr_dec;
      output logic [63:0] WriteData_dec;
      output logic [4:0] Rd_dec;

      register_64 writedata_pl(.q(WriteData_dec), .d(WriteData), .reset, .clk);

      register_5 Rd_pl (.q(Rd_dec), .d(Rd), .reset, .clk);

      D_FF regwr_pl (.q(regwr_dec), .d(regwr), .reset, .clk);
endmodule