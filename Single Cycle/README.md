For this project the goal was to create a 64 bit single cycle CPU that uses some basic insructions. This uses an ALU and register file I developed as well. These were mostly implemented using gate level instansiation. The instruction set was defined as follows:

ADDI rd, rn, imm12  <br />
ADDS rd, rn, rm
B imm26
B.LT imm19
CBZ rd, imm19
LDUR rd, \[rn, imm9\]
LDURB rd, \[rm, imm9\]
MOVK rd, imm16, LSL shamt
MOVZ rd, imm16, LSL shamt
STUR rd, \[rn, imm9\]
STURB rd, \[rn, imm9\]
SUBS rd, rn, rm

All of these are implemented with the idea that the clock will be long enough to complete every insruction in this list within the time of a clock period. Basically if the next instruction depends on the output of the last, the output of the last instruction will be updated before the start of the next.
