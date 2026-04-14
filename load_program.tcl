# Load program.txt into instruction memory (sourced by testbench.tcl after vsim).
# Use mem load so values are written into the RAM model (no extra driver vs. force -freeze).

proc load_program {} {
    set fn program.txt
    if {![file isfile $fn]} {
        error "load_program: cannot find $fn (cwd: [pwd])"
    }

    set path /processor/instruction_mem/ram_block
    puts "Loading [file normalize $fn] into $path ..."

    # One 32-bit binary word per line (ASCII '0'/'1'), ascending address from 0.
    mem load -format bin -infile $fn $path

    set f [open $fn r]
    set n 0
    while {[gets $f line] >= 0} {
        set line [string trim $line]
        if {$line ne ""} {
            incr n
            if {$n <= 20} {
                puts "  word [expr {$n - 1}]: $line"
            }
        }
    }
    close $f
    puts "Loaded $n instruction word(s)."
}

load_program
