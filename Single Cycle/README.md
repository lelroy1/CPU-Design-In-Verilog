For this project the goal was to create a 64 bit single cycle CPU that uses some basic insructions. This uses an ALU and register file I developed as well. These were mostly implemented using gate level instansiation. The instruction set was defined as follows:

ADDI rd, rn, imm12  <br />
ADDS rd, rn, rm  <br />
B imm26  <br />
B.LT imm19  <br />
CBZ rd, imm19  <br />
LDUR rd, \[rn, imm9\]  <br />
LDURB rd, \[rm, imm9\]  <br />
MOVK rd, imm16, LSL shamt  <br />
MOVZ rd, imm16, LSL shamt  <br />
STUR rd, \[rn, imm9\]  <br />
STURB rd, \[rn, imm9\]  <br />
SUBS rd, rn, rm  <br />

All of these are implemented with the idea that the clock will be long enough to complete every insruction in this list within the time of a clock period. Basically if the next instruction depends on the output of the last, the output of the last instruction will be updated before the start of the next.
