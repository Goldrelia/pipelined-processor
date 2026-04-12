# pipelined-processor

<img width="694" height="502" alt="image" src="https://github.com/user-attachments/assets/acbe6414-da13-4f05-a01a-904fb7a92422" />

Updated, more detailed?
<img width="450" height="698" alt="image" src="https://github.com/user-attachments/assets/f41ba3fb-cda5-4105-91ab-2558e6947455" />


<img width="1057" height="537" alt="image" src="https://github.com/user-attachments/assets/7ef345a2-b95a-4029-a683-770978ec2f25" />

We must work on different aspects of the layers of the architecture. 

Layer 1:

2:1 MUX and adder -> Yasmine

Sign-extender / Imm-Gen -> Matthew

Layer 2:

Register file -> Aurelia

Instruction MEM and Data MEM -> Yasmine

ALU and Control Unit --> Tayba

Layer 3:

Pipeline Registers -> Matthew

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
