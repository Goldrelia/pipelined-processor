# Script to dump register file and memory contents after simulation
# Run this after the main testbench completes

# Open output files
set reg_file [open "register_file.txt" w]
set mem_file [open "memory.txt" w]

# Dump register file (32 registers, 32 bits each in binary)
puts "Dumping register file..."
for {set i 0} {$i < 32} {incr i} {
    # Attempt to read register from processor's internal register_file
    # Try multiple possible paths (depends on VHDL hierarchy)
    set found 0
    set reg_value ""
    
    # Try path 1: /processor/register_file/regs
    if {[catch {set reg_value [examine -binary /processor/register_file/regs\($i\)]} err] == 0 && $reg_value != ""} {
        set found 1
    }
    
    # Try path 2: /testbench/dut/register_file/regs
    if {!$found && [catch {set reg_value [examine -binary /testbench/dut/register_file/regs\($i\)]} err] == 0 && $reg_value != ""} {
        set found 1
    }
    
    # Try path 3: Use the register_file component directly
    if {!$found && [catch {set reg_value [examine -binary /work.register_file_regs\($i\)]} err] == 0 && $reg_value != ""} {
        set found 1
    }
    
    if {$found} {
        # Pad to 32 bits if needed
        set padded [format "%032s" [string map {x 0 X 0} $reg_value]]
        puts $reg_file $padded
    } else {
        # Write zeros as placeholder
        puts $reg_file "00000000000000000000000000000000"
    }
}
close $reg_file

# Dump data memory (8192 words, 32 bits each in binary)
puts "Dumping data memory..."
for {set i 0} {$i < 8192} {incr i} {
    set found 0
    set mem_word ""
    
    # Try path 1: /processor/data_mem/mem (or memory)
    if {[catch {set mem_word [examine -binary /processor/data_mem/mem\($i\)]} err] == 0 && $mem_word != ""} {
        set found 1
    }
    
    # Try path 2: /processor/memory_2/mem
    if {!$found && [catch {set mem_word [examine -binary /processor/memory_2/mem\($i\)]} err] == 0 && $mem_word != ""} {
        set found 1
    }
    
    # Try path 3: /testbench/data_mem/mem
    if {!$found && [catch {set mem_word [examine -binary /testbench/data_mem/mem\($i\)]} err] == 0 && $mem_word != ""} {
        set found 1
    }
    
    if {$found} {
        set padded [format "%032s" [string map {x 0 X 0} $mem_word]]
        puts $mem_file $padded
    } else {
        puts $mem_file "00000000000000000000000000000000"
    }
}
close $mem_file

puts "Output files created: register_file.txt, memory.txt"
puts "Register file written to: register_file.txt"
puts "Data memory written to: memory.txt"
