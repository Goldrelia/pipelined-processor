# Load program.txt into instruction memory using TCL/ModelSim force command
# This is sourced after simulation starts but before running

set f [open "program.txt" r]
set addr 0

puts "Loading program.txt into instruction memory..."

while {[gets $f line] >= 0} {
    if {$line != "" && [string length $line] == 32} {
        # Force the instruction into instruction_mem's ram_block
        force -freeze /processor/instruction_mem/ram_block\($addr\) $line -radix binary
        
        if {$addr < 12} {
            puts "  Instr\[$addr\]: $line"
        }
        incr addr
    }
}
close $f

puts "✓ Loaded $addr instructions into instruction memory\n"
