# pipelined-processor

Files to delete?

branch_logic.vhd
adder.vhd
MUX_2_1.vhd
testbench.vhd

Reasons:
branch_logic.vhd: we handle branch conditions directly in processor.vhd with the branch_condition_ex signal, so this component is never instantiated
adder.vhd: we use the MUX_2_1_32bit and compute additions inline with std_logic_vector(unsigned(PC) + 4), never instantiate this
MUX_2_1.vhd: we only ever use MUX_2_1_32bit, never the 1-bit version
testbench.vhd: program loading is done via TCL, this file is never compiled or used
