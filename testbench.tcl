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
vcom -work work adder.vhd
vcom -work work alu.vhd
vcom -work work control.vhd
vcom -work work generic_register.vhd
vcom -work work register.vhd
vcom -work work memory.vhd
vcom -work work MUX_2_1.vhd
vcom -work work MUX_2_1_32bit.vhd
vcom -work work register_file.vhd
vcom -work work imm_gen.vhd
vcom -work work if_id_register.vhd
vcom -work work id_ex_register.vhd
vcom -work work ex_mem_register.vhd
vcom -work work mem_wb_register.vhd
vcom -work work processor.vhd

puts "✓ Compilation complete\n"

puts "Starting simulation..."
# vsim -c work.processor
# changed 
# TODO: check if good
vsim -c work.processor
force /processor/reset 1 0ns, 0 5ns
force /processor/clk 0 0ns, 1 0.5ns -repeat 1ns
run 10ns

puts "✓ Simulation started\n"

puts "Loading program.txt into instruction memory..."
source load_program.do

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
puts "Run verification:"
puts "  python3 verify_output.py"
puts "=================================================="

quit -sim
