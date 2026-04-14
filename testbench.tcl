# Complete testbench script for RISC-V pipelined processor
# This script compiles, simulates, and dumps output files
# NOTE: program.txt is loaded into instruction memory via TCL (load_program.do)

puts "=================================================="
puts "RISC-V Pipelined Processor Testbench"
puts "=================================================="

# Create work library
vlib work
vmap work work

puts "\nCompiling VHDL files..."

# Compile in dependency order
vcom -2008 -work work alu.vhd
vcom -2008 -work work control.vhd
vcom -2008 -work work generic_register.vhd
vcom -2008 -work work register.vhd
vcom -2008 -work work memory.vhd
vcom -2008 -work work MUX_2_1_32bit.vhd
vcom -2008 -work work register_file.vhd
vcom -2008 -work work imm_gen.vhd
vcom -2008 -work work if_id_register.vhd
vcom -2008 -work work id_ex_register.vhd
vcom -2008 -work work ex_mem_register.vhd
vcom -2008 -work work mem_wb_register.vhd
vcom -2008 -work work control_hazard.vhd
vcom -2008 -work work processor.vhd

puts "✓ Compilation complete\n"

puts "Starting simulation..."
vsim -c work.processor
force /processor/clk 0 0, 1 500ps -repeat 1ns
force /processor/reset 1 0ns

run 5ns 

puts "✓ Simulation started\n"

puts "Loading program.txt into instruction memory..."
source load_program.tcl

force /processor/reset 0 0ns 

puts "Running for 10,000 cycles..."
run 10000 ns

puts "✓ Simulation complete\n"

puts "Dumping register_file.txt (32 registers)..."
set rf [open "register_file.txt" w]
for {set i 0} {$i < 32} {incr i} {
    set val [examine -binary /processor/register_file/regs\($i\)]
    puts $rf $val
    if {$i == 10} {
        puts "  x10 (a0) = $val"
    }
}
close $rf
puts "✓ Written to register_file.txt\n"

puts "Dumping memory.txt (8192 words)..."
set mf [open "memory.txt" w]
for {set i 0} {$i < 8192} {incr i} {
    set val [examine -binary /processor/data_mem/ram_block\($i\)]
    puts $mf $val
    if {$i % 1024 == 0} {
        puts "  Progress: $i / 8192 words written"
    }
}
close $mf
puts "✓ Written to memory.txt\n"

puts "=================================================="
puts "✓ All files generated successfully!"
puts "=================================================="
puts "Output files:"
puts "  - register_file.txt (32 lines)"
puts "  - memory.txt (8192 lines)"
puts ""
puts "=================================================="

quit -sim