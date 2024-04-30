onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -label instruction /cpu_tb/dut/path/instruction
add wave -noupdate -label clk /cpu_tb/clk
add wave -noupdate -label reset /cpu_tb/reset
add wave -noupdate -label programcount -radix decimal /cpu_tb/dut/path/programcount
add wave -noupdate -label programcountnext -radix decimal /cpu_tb/dut/path/programcountnext
add wave -noupdate -label negative /cpu_tb/dut/negative
add wave -noupdate -label overflow /cpu_tb/dut/overflow
add wave -noupdate -label zero /cpu_tb/dut/zero
add wave -noupdate -label {zero_alu (used for CBZ)} /cpu_tb/dut/control/zero_alu
add wave -noupdate -label carry_out /cpu_tb/dut/carry_out
add wave -noupdate -label {Rd (WriteRegister)} /cpu_tb/dut/path/Rd
add wave -noupdate -label {Rn (ReadRegister1)} /cpu_tb/dut/path/Rn
add wave -noupdate -label ReadRegister2 /cpu_tb/dut/path/ReadRegister2
add wave -noupdate -label ReadData1 -radix hexadecimal /cpu_tb/dut/path/ReadData1
add wave -noupdate -label ReadData2 -radix hexadecimal /cpu_tb/dut/path/ReadData2
add wave -noupdate -label WriteData -radix hexadecimal /cpu_tb/dut/path/WriteData
add wave -noupdate -label {alu_result (address)} -radix hexadecimal /cpu_tb/dut/path/alu_result
add wave -noupdate -label mem_write_data -radix hexadecimal /cpu_tb/dut/path/mem_write_data
add wave -noupdate -label mem_read_data -radix hexadecimal /cpu_tb/dut/path/mem_read_data
add wave -noupdate -label X0 -radix decimal {/cpu_tb/dut/path/regfilemodule/eachDff[0]/regs/out}
add wave -noupdate -label X1 -radix decimal {/cpu_tb/dut/path/regfilemodule/eachDff[1]/regs/out}
add wave -noupdate -label X2 -radix decimal {/cpu_tb/dut/path/regfilemodule/eachDff[2]/regs/out}
add wave -noupdate -label X3 -radix decimal {/cpu_tb/dut/path/regfilemodule/eachDff[3]/regs/out}
add wave -noupdate -label X4 -radix decimal {/cpu_tb/dut/path/regfilemodule/eachDff[4]/regs/out}
add wave -noupdate -label X5 -radix decimal {/cpu_tb/dut/path/regfilemodule/eachDff[5]/regs/out}
add wave -noupdate -label X6 -radix decimal {/cpu_tb/dut/path/regfilemodule/eachDff[6]/regs/out}
add wave -noupdate -label X7 -radix decimal {/cpu_tb/dut/path/regfilemodule/eachDff[7]/regs/out}
add wave -noupdate -label X8 -radix decimal {/cpu_tb/dut/path/regfilemodule/eachDff[8]/regs/out}
add wave -noupdate -label X9 -radix decimal {/cpu_tb/dut/path/regfilemodule/eachDff[9]/regs/out}
add wave -noupdate -label X10 -radix decimal {/cpu_tb/dut/path/regfilemodule/eachDff[10]/regs/out}
add wave -noupdate -label X11 -radix decimal {/cpu_tb/dut/path/regfilemodule/eachDff[11]/regs/out}
add wave -noupdate -label X12 -radix decimal {/cpu_tb/dut/path/regfilemodule/eachDff[12]/regs/out}
add wave -noupdate -label X13 -radix decimal {/cpu_tb/dut/path/regfilemodule/eachDff[13]/regs/out}
add wave -noupdate -label X14 -radix decimal {/cpu_tb/dut/path/regfilemodule/eachDff[14]/regs/out}
add wave -noupdate -label X15 -radix decimal {/cpu_tb/dut/path/regfilemodule/eachDff[15]/regs/out}
add wave -noupdate -label X16 -radix decimal {/cpu_tb/dut/path/regfilemodule/eachDff[16]/regs/out}
add wave -noupdate -label X17 -radix decimal {/cpu_tb/dut/path/regfilemodule/eachDff[17]/regs/out}
add wave -noupdate -label X18 -radix decimal {/cpu_tb/dut/path/regfilemodule/eachDff[18]/regs/out}
add wave -noupdate -label X19 -radix decimal {/cpu_tb/dut/path/regfilemodule/eachDff[19]/regs/out}
add wave -noupdate -label X20 -radix decimal {/cpu_tb/dut/path/regfilemodule/eachDff[20]/regs/out}
add wave -noupdate -label X21 -radix decimal {/cpu_tb/dut/path/regfilemodule/eachDff[21]/regs/out}
add wave -noupdate -label X22 -radix decimal {/cpu_tb/dut/path/regfilemodule/eachDff[22]/regs/out}
add wave -noupdate -label X23 -radix decimal {/cpu_tb/dut/path/regfilemodule/eachDff[23]/regs/out}
add wave -noupdate -label X24 -radix decimal {/cpu_tb/dut/path/regfilemodule/eachDff[24]/regs/out}
add wave -noupdate -label X25 -radix decimal {/cpu_tb/dut/path/regfilemodule/eachDff[25]/regs/out}
add wave -noupdate -label X26 -radix decimal {/cpu_tb/dut/path/regfilemodule/eachDff[26]/regs/out}
add wave -noupdate -label X27 -radix decimal {/cpu_tb/dut/path/regfilemodule/eachDff[27]/regs/out}
add wave -noupdate -label X28 -radix decimal {/cpu_tb/dut/path/regfilemodule/eachDff[28]/regs/out}
add wave -noupdate -label X29 -radix decimal {/cpu_tb/dut/path/regfilemodule/eachDff[29]/regs/out}
add wave -noupdate -label X30 -radix decimal {/cpu_tb/dut/path/regfilemodule/eachDff[30]/regs/out}
add wave -noupdate -label X31 -radix decimal {/cpu_tb/dut/path/regfilemodule/mux_wires[31]}
add wave -noupdate -label mainmemory -childformat {{{/cpu_tb/dut/path/mainmemory/mem[87]} -radix hexadecimal} {{/cpu_tb/dut/path/mainmemory/mem[86]} -radix hexadecimal} {{/cpu_tb/dut/path/mainmemory/mem[85]} -radix hexadecimal} {{/cpu_tb/dut/path/mainmemory/mem[84]} -radix hexadecimal} {{/cpu_tb/dut/path/mainmemory/mem[83]} -radix hexadecimal} {{/cpu_tb/dut/path/mainmemory/mem[82]} -radix hexadecimal} {{/cpu_tb/dut/path/mainmemory/mem[81]} -radix hexadecimal} {{/cpu_tb/dut/path/mainmemory/mem[80]} -radix hexadecimal}} -subitemconfig {{/cpu_tb/dut/path/mainmemory/mem[87]} {-height 15 -radix hexadecimal} {/cpu_tb/dut/path/mainmemory/mem[86]} {-height 15 -radix hexadecimal} {/cpu_tb/dut/path/mainmemory/mem[85]} {-height 15 -radix hexadecimal} {/cpu_tb/dut/path/mainmemory/mem[84]} {-height 15 -radix hexadecimal} {/cpu_tb/dut/path/mainmemory/mem[83]} {-height 15 -radix hexadecimal} {/cpu_tb/dut/path/mainmemory/mem[82]} {-height 15 -radix hexadecimal} {/cpu_tb/dut/path/mainmemory/mem[81]} {-height 15 -radix hexadecimal} {/cpu_tb/dut/path/mainmemory/mem[80]} {-height 15 -radix hexadecimal}} /cpu_tb/dut/path/mainmemory/mem
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {324951743 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 208
configure wave -valuecolwidth 113
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {3154937500 ps} {5228687500 ps}
