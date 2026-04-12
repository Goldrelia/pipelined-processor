# Script to load program.txt into instruction memory
# This is sourced before simulation starts

proc load_program {} {
    # Read program.txt and load instructions into memory
    set f [open "program.txt" r]
    set addr 0
    
    puts "Loading program.txt into instruction memory..."
    
    while {[gets $f line] >= 0} {
        if {$line != ""} {
            # Convert binary string to forces into memory
            force /processor/instruction_mem/ram_block($addr) $line
            # Note: Need to figure out correct path to instruction memory
            
            if {$addr < 20} {
                puts "  Instruction $addr: $line"
            }
            incr addr
        }
    }
    close $f
    
    puts "Loaded $addr instructions"
}

load_program
