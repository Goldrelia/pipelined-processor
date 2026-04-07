# Testbench for pipelined RISC-V processor
# Reads program from program.txt, runs for 10,000 cycles, writes outputs

# Assume using ModelSim or similar simulator
# Compile all VHDL files first

vlib work
vmap work work

# Compile VHDL files (adjust paths as needed)
vcom -work work adder.vhd
vcom -work work alu.vhd
vcom -work work control.vhd
vcom -work work ex_mem_register.vhd
vcom -work work generic_register.vhd
vcom -work work id_ex_register.vhd
vcom -work work if_id_register.vhd
vcom -work work imm_gen.vhd
vcom -work work mem_wb_register.vhd
vcom -work work memory.vhd
vcom -work work mux_2_1.vhd
vcom -work work MUX_2_1_32bit.vhd
vcom -work work register.vhd
vcom -work work register_file.vhd
vcom -work work processor.vhd

# Start simulation
vsim -c work.processor

# Add waves if needed
# add wave *

# Run for 10,000 cycles (at 1 GHz, but simulator time is arbitrary)
run 10000 ns

# Source the dump script to write output files
source dump_output.tcl

quit -sim