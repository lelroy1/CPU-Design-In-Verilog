For this project the goal was to create a 64 bit pipelined CPU that uses some basic insructions. This uses an ALU and register file I developed as well. These were mostly implemented using gate level instansiation. The instruction set was defined as follows:

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

The 5 stages of this pipelined CPU are as follows: Instruction Fetch (IF): store the instruction op code within instruction memory and compute accelerated branching, Register Fetch (RF): read all needed CPU registers into the CPU, does forwarding from execution and memory stages to insure overwritten registers are accurate, does accelerated branching for just CBZ, Execution (EX): does all math and updates flags needed for branching and conditionals, Memory (MEM): stores and loads memory to and from main memory, Write Back (WB): writes registers into the CPU that were modified in execution or memory stages. It was also decided that there will be a NO OP instruction after every load and branch instruction to make the system simpler. It is possible to constrict this further but in order to do that you need to use superscalar and have the ability to rearrange instructions dynamically. This is out of the scope of this project, but I am currently looking into developing this as well. That will likely be a multi year personal project.
