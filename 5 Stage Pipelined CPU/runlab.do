# Create work library
vlib work

# Compile Verilog
#     All Verilog files that are part of this design should have
#     their own "vlog" line below.
vlog "./adder.sv"
vlog "./alu.sv"
vlog "./muxs.sv"
vlog "./bitslice.sv"
vlog "./controller.sv"
vlog "./cpu.sv"
vlog "./D_FF.sv"
vlog "./datamem.sv"
vlog "./datapath_pl.sv"
vlog "./decoders.sv"
vlog "./extends.sv"
vlog "./instructmem.sv"
vlog "./regfile.sv"
vlog "./shift.sv"
vlog "./bitslice.sv"
vlog "./pl_registers.sv"

# Call vsim to invoke simulator
#     Make sure the last item on the line is the name of the
#     testbench module you want to execute.
vsim -voptargs="+acc" -t 1ps -lib work cpu_tb

# Source the wave do file
#     This should be the file that sets up the signal window for
#     the module you are testing.
do cpu_wave.do

# Set the window types
view wave
view structure
view signals

# Run the simulation
run -all

# End
